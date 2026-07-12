#!/usr/bin/env python3
"""Filter an audio file through the sys_fir_filter FPGA design and check it.

    make program DESIGN=sys_fir_filter
    python3 py/fir_audio.py

Sends INPUT (any WAV) sample-by-sample, reads back the filtered samples, writes
OUTPUT, and - if REFERENCE is set - checks they match exactly. Send in 32-byte
chunks (the bridge's buffer size), reading each chunk back, since there is no
hardware flow control. PORT is the board's serial port (/dev/ttyUSB1 in WSL).
"""
import numpy as np
import serial
from scipy.io import wavfile

PORT      = "/dev/ttyUSB1"
BAUD      = 2_000_000
CHUNK     = 32
INPUT     = "data/chill_sub.wav"
OUTPUT    = "data/fpga_out.wav"
REFERENCE = "data/bass_only_8bit.wav"   # None to skip the check
SECONDS   = 1                            # None for the whole file

# ---- Quantize the source to signed int8 (mono), matching sys_fir_filter_gen ---
fs, source = wavfile.read(INPUT)
samples = source.astype(np.float32)
if samples.ndim > 1:
    samples = samples.mean(axis=1)
samples = np.clip(np.round(samples * 128), -128, 127).astype(np.int8)
if SECONDS:
    samples = samples[:SECONDS * fs]

# ---- Stream through the FPGA, reading each chunk back -------------------------
ser = serial.Serial(PORT, BAUD, timeout=2)
raw = samples.tobytes()
out = bytearray()
for i in range(0, len(raw), CHUNK):
    ser.write(raw[i:i + CHUNK])
    ser.flush()
    out += ser.read(len(raw[i:i + CHUNK]))
ser.close()

filtered = np.frombuffer(bytes(out), dtype=np.int8)
result   = (filtered.astype(np.int16) + 128).astype(np.uint8)   # int8 -> uint8 WAV
wavfile.write(OUTPUT, fs, result)
print(f"Filtered {len(samples)} samples -> {OUTPUT}")

if REFERENCE:
    _, reference = wavfile.read(REFERENCE)
    reference = reference[:len(result)]
    if np.array_equal(result, reference):
        print(f"PASS: all {len(result)} samples match {REFERENCE}.")
    else:
        print(f"FAIL: {(result != reference).sum()} samples differ from {REFERENCE}.")
