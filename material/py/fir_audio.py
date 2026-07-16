#!/usr/bin/env python3
"""Filter an audio file through the sys_fir_filter FPGA design and check it.

    make program_fpga DESIGN=sys_fir_filter
    python3 /path/to/digital-design/material/py/fir_audio.py

Sends INPUT (any WAV) sample-by-sample, reads back the filtered samples, writes
OUTPUT, and - if REFERENCE is set - checks they match exactly. Send in 32-byte
chunks (the bridge's buffer size), reading each chunk back, since there is no
hardware flow control. PORT is the board's serial port (/dev/ttyUSB1 in WSL).
"""
from pathlib import Path

import numpy as np
import serial
from scipy.io import wavfile

PORT      = "/dev/ttyUSB1"
BAUD      = 2_000_000
CHUNK     = 32
DATA_DIR  = Path(__file__).resolve().parent.parent / "data"
INPUT     = DATA_DIR / "chill_sub.wav"
OUTPUT    = DATA_DIR / "fpga_out.wav"
REFERENCE = DATA_DIR / "bass_only_8bit.wav"   # None to skip the check
SECONDS   = None                        # None for the whole file
WARMUP    = 101                         # N+1 taps: the FPGA keeps the delay line
                                        # from the previous run, so its first N+1
                                        # outputs mix in stale samples while the
                                        # reference starts from zeros. Skip them.

# ---- Quantize the source to signed int8 (mono), matching sys_fir_filter_gen ---
fs, source = wavfile.read(INPUT)
samples = source.astype(np.float32)
if samples.ndim > 1:
    samples = samples.mean(axis=1)
samples = np.clip(np.round(samples * 128), -128, 127).astype(np.int8)
if SECONDS:
    samples = samples[:SECONDS * fs]

# ---- Stream through the FPGA, reading each chunk back -------------------------
raw = samples.tobytes()
out = bytearray()
next_progress = 2
with serial.Serial(PORT, BAUD) as ser:
    ser.reset_input_buffer()
    for i in range(0, len(raw), CHUNK):
        chunk = raw[i:i + CHUNK]
        ser.write(chunk)
        out += ser.read(len(chunk))
        if 100 * len(out) >= next_progress * len(raw):
            print(f"{next_progress}% done", flush=True)
            next_progress += 2

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
