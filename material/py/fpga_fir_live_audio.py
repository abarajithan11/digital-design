#!/usr/bin/env python3
"""Filter live microphone audio through the sys_fir_filter FPGA design.

    make program_fpga DESIGN=sys_fir_filter
    python3 /path/to/digital-design/material/py/fpga_fir_live_audio.py --port PORT

Records from the default input, streams the samples through the FPGA and plays
the filtered ones on the default output. You should hear only the bass. Ctrl-C
to stop.

The board's USB bridge MCU has no hardware flow control and only a BURST-byte
buffer, so writing faster than it drains loses samples before the FPGA sees
them (the same reason fpga_fir_offline.py chunks). A writer thread therefore paces the
link; it cannot live in the audio callback, which delivers a whole block at
once. A reader thread collects the filtered bytes, which come back a few ms
later, and PREFILL of them are buffered before playback starts so normal jitter
does not starve the output. PORT is the board's serial port.

Pick devices with --input/--output (--list shows them). Note that on WSL there
is nothing to pick: WSLg proxies audio to Windows and exposes exactly one mic
(RDPSource) and one speaker (RDPSink), so choose the real devices in Windows'
Sound settings instead. On Linux, the audio dependency set also needs the
PortAudio runtime supplied by the distribution.
"""
import argparse
import queue
import threading
import time

import numpy as np

from utils import add_port_argument, open_serial

BAUD  = 2_000_000
BURST = 32       # the bridge MCU's buffer size - never write more at once
BLOCK = 512      # samples per audio callback
RATE  = 44100    # the rate the filter's coefficients were designed for
# Time for the MCU to shift a full BURST out at BAUD (10 bits/byte), plus 25%
# margin. Writing faster than this overflows its buffer: there is no flow control.
MIN_GAP = 1.25 * BURST * 10 / BAUD
PREFILL = 4 * BLOCK   # filtered bytes buffered before playback (~46 ms)

parser = argparse.ArgumentParser(description=__doc__,
                                 formatter_class=argparse.RawDescriptionHelpFormatter)
parser.add_argument("--list", action="store_true", help="list audio devices and exit")
parser.add_argument("-i", "--input", help="input device: index or name substring")
parser.add_argument("-o", "--output", help="output device: index or name substring")
add_port_argument(parser)
args = parser.parse_args()

# Import after argument parsing so --help works even before PortAudio is installed.
import sounddevice as sd

if not len(sd.query_devices()):
    raise SystemExit(
        "PortAudio sees no audio devices.\n"
        "  - Run with /usr/bin/python3: conda's PortAudio has no PulseAudio support.\n"
        "  - On WSL also: apt install libportaudio2 libasound2-plugins, and point\n"
        "    ALSA at pulse (pcm.!default { type pulse } in /etc/asound.conf).")

if args.list:
    print(sd.query_devices())
    raise SystemExit

def device(spec):
    """An index, or a name substring for sounddevice to match. None = default."""
    if spec is None:
        return None
    try:
        return int(spec)
    except ValueError:
        return spec

to_fpga = queue.Queue()         # int8 blocks from the mic
from_fpga = bytearray()         # filtered bytes, filled by the reader thread
lock = threading.Lock()
playing = False                 # False until PREFILL bytes have arrived


def writer(ser):
    """Send BURST bytes at a time, never faster than the bridge MCU drains.

    The Tang Nano 20K's MCU buffers USB->UART in BURST bytes with no hardware
    flow control, and empties it at the baud rate, so two writes closer together
    than BURST*10/BAUD seconds overflow it and the samples are gone before the
    FPGA sees them. MIN_GAP enforces that floor even when this thread has been
    descheduled and is behind - catching up by bursting is what loses data. At
    2 Mbaud the floor is 160 us while audio only needs a write every 726 us, so
    there is ~4.5x of room to catch up within.
    """
    due = floor = time.perf_counter()
    while True:
        raw = to_fpga.get().tobytes()
        for i in range(0, len(raw), BURST):
            # Target the audio rate: the board echoes one byte per byte sent, so
            # sending faster than RATE only makes the return path overrun. If we
            # were descheduled and are behind, catch up no faster than MIN_GAP.
            due = max(due + BURST / RATE, floor)
            while time.perf_counter() < due:   # sub-ms: too fine for time.sleep
                pass
            ser.write(raw[i:i + BURST])
            floor = time.perf_counter() + MIN_GAP


def reader(ser):
    """Collect filtered bytes for as long as the board sends them."""
    while True:
        chunk = ser.read(1) + ser.read(ser.in_waiting or 0)
        with lock:
            from_fpga.extend(chunk)


def callback(indata, outdata, frames, time_info, status):
    global playing
    # float [-1,1] -> int8, matching fpga_fir_offline.py's quantization
    to_fpga.put(np.clip(np.round(indata[:, 0] * 128), -128, 127).astype(np.int8))
    outdata[:] = 0                      # silence until the board's reply arrives
    with lock:
        if not playing and len(from_fpga) >= PREFILL:
            playing = True
        if playing and len(from_fpga) >= frames:
            y = np.frombuffer(bytes(from_fpga[:frames]), dtype=np.int8)
            del from_fpga[:frames]
            outdata[:, 0] = y.astype(np.float32) / 128.0


with open_serial(args.port, BAUD, timeout=0.1) as ser:
    ser.reset_input_buffer()
    threading.Thread(target=writer, args=(ser,), daemon=True).start()
    threading.Thread(target=reader, args=(ser,), daemon=True).start()

    with sd.Stream(samplerate=RATE, blocksize=BLOCK, dtype="float32",
                   channels=1, device=(device(args.input), device(args.output)),
                   callback=callback):
        print(f"Filtering mic -> FPGA -> speakers at {RATE} Hz. Ctrl-C to stop.")
        try:
            while True:
                sd.sleep(1000)
        except KeyboardInterrupt:
            print("\nStopped.")
