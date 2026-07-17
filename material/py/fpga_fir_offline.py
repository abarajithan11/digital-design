#!/usr/bin/env python3
"""Filter an audio file through the sys_fir_filter FPGA design and check it.

    make program_fpga DESIGN=sys_fir_filter
    python3 /path/to/digital-design/material/py/fpga_fir_offline.py --port PORT

Sends INPUT (any WAV) sample-by-sample, reads back the filtered samples, writes
OUTPUT, and - if REFERENCE is set - checks they match exactly.

The board's USB bridge MCU has no hardware flow control and only a CHUNK-byte
buffer, so writing faster than it drains silently loses samples before the FPGA
sees them - and one lost byte shifts the whole stream, so it is never a small
error. Rather than wait for each chunk to come back (which would serialise a
~6ms USB round trip per 32 bytes and take minutes), we pace the writes and let
a reader thread collect the replies as they arrive.
"""
import argparse
import threading
import time
import urllib.request
from pathlib import Path

import numpy as np
from scipy.io import wavfile

from utils import add_port_argument, open_serial

BAUD      = 2_000_000
CHUNK     = 32                          # the bridge MCU's buffer size
WINDOW    = 64                          # max bytes in flight (see below). Measured:
                                        # 64 is lossless, 256 and 1024 both drop.
MIN_GAP   = 1.25 * CHUNK * 10 / BAUD    # time for the MCU to drain one CHUNK at
                                        # BAUD (10 bits/byte), plus 25% margin
DATA_DIR  = Path(__file__).resolve().parent.parent / "data"
INPUT     = DATA_DIR / "chill_sub.wav"
DOWNLOAD_URL = "https://media.abapages.com/course-site/chill_sub.wav"
OUTPUT    = DATA_DIR / "fpga_out.wav"
REFERENCE = DATA_DIR / "bass_only_8bit.wav"   # None to skip the check
SECONDS   = None                        # None for the whole file
WARMUP    = 101                         # N+1 taps: the FPGA keeps the delay line
                                        # from the previous run, so its first N+1
                                        # outputs mix in stale samples while the
                                        # reference starts from zeros. Skip them.

parser = argparse.ArgumentParser(description=__doc__,
                                 formatter_class=argparse.RawDescriptionHelpFormatter)
add_port_argument(parser)
args = parser.parse_args()

# ---- Download the source audio if it is not already available -----------------
DATA_DIR.mkdir(parents=True, exist_ok=True)
if not INPUT.is_file():
    print(f"{INPUT} not found. Downloading from {DOWNLOAD_URL} ...")
    req = urllib.request.Request(DOWNLOAD_URL, headers={"User-Agent": "Mozilla/5.0", "Accept": "*/*"})
    with urllib.request.urlopen(req) as response, INPUT.open("wb") as f:
        f.write(response.read())

# ---- Quantize the source to signed int8 (mono), matching sys_fir_filter_gen ---
fs, source = wavfile.read(INPUT)
samples = source.astype(np.float32)
if samples.ndim > 1:
    samples = samples.mean(axis=1)
samples = np.clip(np.round(samples * 128), -128, 127).astype(np.int8)
if SECONDS:
    samples = samples[:SECONDS * fs]

# ---- Stream through the FPGA, collecting the replies in the background --------
raw = samples.tobytes()
out = bytearray()

with open_serial(args.port, BAUD, timeout=2) as ser:
    ser.reset_input_buffer()

    def reader():
        while len(out) < len(raw):
            chunk = ser.read(1)          # blocks until the board replies
            if not chunk:
                return                   # timed out: samples were lost
            out.extend(chunk)
            out.extend(ser.read(ser.in_waiting or 0))

    collector = threading.Thread(target=reader, daemon=True)
    collector.start()

    next_progress = 2
    floor = time.perf_counter()
    for i in range(0, len(raw), CHUNK):
        # Credit-based flow control. Bytes in flight are exactly the bytes queued
        # in the bridge's tiny return buffer, so bounding them bounds that queue:
        # if the host ever falls behind, credits dry up and we stall instead of
        # overflowing it. A fixed send rate cannot do this - it has no idea the
        # host stalled, and one lost byte shifts the whole stream.
        while i - len(out) > WINDOW:
            time.sleep(0)                    # yields, so the reader can drain
        # Also never hand the MCU a new CHUNK before it has drained the last.
        while time.perf_counter() < floor:
            time.sleep(0)
        ser.write(raw[i:i + CHUNK])
        floor = time.perf_counter() + MIN_GAP
        if 100 * i >= next_progress * len(raw):
            print(f"{next_progress}% done", flush=True)
            next_progress += 2
    collector.join(timeout=5)

if len(out) != len(raw):
    raise SystemExit(f"Lost {len(raw) - len(out)} of {len(raw)} samples in transit "
                     f"- the bridge overflowed. Lower WINDOW (currently {WINDOW}).")

filtered = np.frombuffer(bytes(out), dtype=np.int8)
result   = (filtered.astype(np.int16) + 128).astype(np.uint8)   # int8 -> uint8 WAV
wavfile.write(OUTPUT, fs, result)
print(f"Filtered {len(samples)} samples, stored in {OUTPUT}")

if REFERENCE:
    _, reference = wavfile.read(REFERENCE)
    reference = reference[:len(result)]
    got, want = result[WARMUP:], reference[WARMUP:]
    if np.array_equal(got, want):
        print(f"PASS: all {len(got)} samples match {REFERENCE}.")
    else:
        print(f"FAIL: {(got != want).sum()} samples differ from {REFERENCE}.")
