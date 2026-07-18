#!/usr/bin/env python3
"""Classify webcam frames continuously with the sys_nn FPGA design.

    # From assignments/a4:
    make bitstream
    # Program fpga/build/sys_nn/sys_nn.fs with openFPGALoader Web.
    # From digital-design:
    python3 material/py/fpga_nn_camera.py

The preview shows the quantized 9x9 image seen by the FPGA, enlarged to 90x90.
Show a dark handwritten digit on a light background. The Tang Nano UART is
detected automatically; ``--port`` overrides it when needed. Press q to stop.
"""
import argparse
import time

import cv2
import numpy as np

from utils import add_port_argument, open_serial

BAUD         = 2_000_000
TIMEOUT      = 1
STARTUP_DRAIN_TIME = 0.1
INTER_BYTE_DELAY   = 1e-3
REQUEST_REPETITIONS = 2
CAMERA       = 0
INPUT_SCALE  = 8             # must equal 2**INPUT_SCALE_LOG2 in nn_weights.sv
SAMPLE_RATE  = 10

parser = argparse.ArgumentParser(description=__doc__)
add_port_argument(parser)
parser.add_argument("--camera", type=int, default=CAMERA,
                    help=f"webcam device number (default: {CAMERA})")
args = parser.parse_args()


def preprocess(frame):
    """Center-crop, threshold, downsample, and quantize a webcam frame."""
    gray = cv2.cvtColor(frame, cv2.COLOR_BGR2GRAY)
    height, width = gray.shape
    side = min(height, width)
    top = (height - side) // 2
    left = (width - side) // 2
    image = gray[top:top + side, left:left + side]

    image = cv2.resize(image, (27, 27), interpolation=cv2.INTER_AREA)
    image = cv2.adaptiveThreshold(
        image, 255,
        cv2.ADAPTIVE_THRESH_GAUSSIAN_C,
        cv2.THRESH_BINARY_INV,
        15, 8,
    )

    image = image.reshape(9, 3, 9, 3).mean(axis=(1, 3))
    return np.clip(np.rint(image * INPUT_SCALE / 255), 0, 7).astype(np.uint8)


def encode(image):
    """Pack a 9x9 int4 image into the FPGA's 41-byte UART packet."""
    values = np.pad(image.reshape(-1), (0, 1))
    return (values[0::2] | (values[1::2] << 4)).tobytes()


def decode(response):
    """Unpack ten signed int4 class scores from five UART bytes."""
    packed = np.frombuffer(response, dtype=np.uint8)
    nibbles = np.column_stack((packed & 0xF, packed >> 4)).reshape(-1)
    return np.where(nibbles & 0x8, nibbles.astype(np.int8) - 16, nibbles).astype(np.int8)


def write_packet(uart, payload):
    """Send one packet with the pacing required by the USB bridge."""
    for value in payload:
        uart.write(bytes((value,)))
        uart.flush()
        time.sleep(INTER_BYTE_DELAY)


camera = cv2.VideoCapture(args.camera)
if not camera.isOpened():
    raise RuntimeError(f"Could not open webcam {args.camera}")

WINDOW = "FPGA input"
cv2.namedWindow(WINDOW, cv2.WINDOW_NORMAL | cv2.WINDOW_KEEPRATIO)
cv2.resizeWindow(WINDOW, 450, 450)

try:
    with open_serial(args.port, BAUD, timeout=TIMEOUT) as uart:
        uart.reset_input_buffer()
        time.sleep(STARTUP_DRAIN_TIME)
        uart.reset_input_buffer()
        print("Streaming webcam predictions; press q to stop.")

        while True:
            start = time.monotonic()
            ok, frame = camera.read()
            if not ok:
                raise RuntimeError("Could not read a webcam frame")

            image = preprocess(frame)
            payload = encode(image)
            for _ in range(REQUEST_REPETITIONS):
                write_packet(uart, payload)
                response = uart.read(5)
                if len(response) != 5:
                    break
            if len(response) != 5:
                raise TimeoutError(f"FPGA returned {len(response)} of 5 score bytes")

            scores = decode(response)
            print(f"prediction={int(scores.argmax())}  scores={scores.tolist()}", flush=True)

            pixels = np.rint(image.astype(float) * 255 / INPUT_SCALE).clip(0, 255).astype(np.uint8)
            preview = cv2.resize(pixels, (90, 90), interpolation=cv2.INTER_CUBIC)
            cv2.imshow(WINDOW, preview)
            if cv2.waitKey(1) & 0xFF in (ord("q"), 27):
                break

            time.sleep(max(0, 1 / SAMPLE_RATE - (time.monotonic() - start)))
except KeyboardInterrupt:
    print("\nStopped.")
finally:
    camera.release()
    cv2.destroyAllWindows()
