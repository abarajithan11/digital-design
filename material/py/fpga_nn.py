#!/usr/bin/env python3
"""Send one MNIST image through the sys_nn FPGA design.

    # From assignments/a4:
    make bitstream
    # Program fpga/build/sys_nn/sys_nn.fs with openFPGALoader Web.
    # From digital-design:
    python3 material/py/fpga_nn.py

Downloads the NumPy-compatible MNIST IDX test files when needed, downsamples
one image to 9x9, quantizes it to unsigned int4 values, sends it to the FPGA,
and prints the ten returned signed int4 scores. The Tang Nano UART is detected
automatically; ``--port`` overrides it when needed.
"""
import argparse
import gzip
from pathlib import Path
import shutil
import time
import urllib.request

import numpy as np

from utils import add_port_argument, open_serial

BAUD        = 2_000_000
TIMEOUT     = 10
STARTUP_DRAIN_TIME = 0.1
INTER_BYTE_DELAY   = 1e-3
REQUEST_REPETITIONS = 2
IMAGE_INDEX = None                         # None selects a random image
INPUT_SCALE = 8                            # must equal 2**INPUT_SCALE_LOG2 in
                                           # nn_weights.sv in digital-design (nn_model.py
                                           # prints it); the FPGA's input quantiser
                                           # scale, re-learned on every retrain.

DATA_DIR = Path(__file__).resolve().parent.parent / "data"
MNIST_DIR = DATA_DIR / "MNIST" / "raw"
IMAGES = MNIST_DIR / "t10k-images-idx3-ubyte"
LABELS = MNIST_DIR / "t10k-labels-idx1-ubyte"
MNIST_URLS = {
    IMAGES: "https://ossci-datasets.s3.amazonaws.com/mnist/t10k-images-idx3-ubyte.gz",
    LABELS: "https://ossci-datasets.s3.amazonaws.com/mnist/t10k-labels-idx1-ubyte.gz",
}

parser = argparse.ArgumentParser(description=__doc__)
add_port_argument(parser)
parser.add_argument("--index", type=int, default=IMAGE_INDEX,
                    help="MNIST test-image index (default: random)")
args = parser.parse_args()


def download_mnist_test_data():
    """Download and decompress either MNIST test IDX file when it is missing."""
    MNIST_DIR.mkdir(parents=True, exist_ok=True)
    for path, url in MNIST_URLS.items():
        if path.is_file():
            continue
        print(f"{path.name} not found; downloading it ...")
        temporary = path.with_name(path.name + ".tmp")
        try:
            with urllib.request.urlopen(url) as response, \
                    gzip.GzipFile(fileobj=response) as source, \
                    temporary.open("wb") as destination:
                shutil.copyfileobj(source, destination)
            temporary.replace(path)
        finally:
            temporary.unlink(missing_ok=True)


download_mnist_test_data()

# ---- Read MNIST and select one test image ------------------------------------
images = np.fromfile(IMAGES, dtype=np.uint8, offset=16).reshape(-1, 28, 28)
labels = np.fromfile(LABELS, dtype=np.uint8, offset=8)
index = args.index
if index is None:
    index = int(np.random.default_rng().integers(len(images)))

image = images[index]
label = int(labels[index])

# ---- Match nn_model.py: 3x3 average pooling, then 4-bit input quantization ----
cropped = image[:27, :27]
downsampled = cropped.reshape(9, 3, 9, 3).mean(axis=(1, 3)) / 255.0
quantized = np.clip(np.rint(downsampled * INPUT_SCALE), 0, 7).astype(np.uint8).reshape(-1)

# x[0] occupies the low nibble. Pad the 81 values to the 328-bit UART packet.
quantized = np.pad(quantized, (0, len(quantized) % 2))
payload = (quantized[0::2] | (quantized[1::2] << 4)).tobytes()

# ---- Run the image through the FPGA ------------------------------------------
with open_serial(args.port, BAUD, timeout=TIMEOUT) as uart:
    # A response from an earlier process can still be arriving through the USB
    # bridge after the port opens. Wait for it to settle, then discard it.
    uart.reset_input_buffer()
    time.sleep(STARTUP_DRAIN_TIME)
    uart.reset_input_buffer()

    # Keep separate writes from collapsing into one USB-bridge burst. Sub-ms
    # sleeps are not consistently honored by every host scheduler. The first
    # result after the packed input changes is unreliable on hardware, so prime
    # the datapath once and use the repeated request's result.
    for _ in range(REQUEST_REPETITIONS):
        for value in payload:
            uart.write(bytes((value,)))
            uart.flush()
            time.sleep(INTER_BYTE_DELAY)
        response = uart.read(5)
        if len(response) != 5:
            break

if len(response) != 5:
    raise TimeoutError(f"FPGA returned {len(response)} of 5 score bytes")

nibbles = np.frombuffer(response, dtype=np.uint8)
nibbles = np.column_stack((nibbles & 0xF, nibbles >> 4)).reshape(-1)
scores = np.where(nibbles & 0x8, nibbles.astype(np.int8) - 16, nibbles).astype(np.int8)
prediction = int(scores.argmax())

print(f"MNIST test image {index}: expected={label}, prediction={prediction}")
print(f"scores={scores.tolist()}")
