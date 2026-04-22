#!/usr/bin/env python3
import os
import urllib.request
import numpy as np
from scipy.signal import firwin
from scipy.io import wavfile

from plot_filter import plot_filter_response

input_file = "data/chill_sub.wav"
output_file = "data/bass_only_8bit.wav"
download_url = "https://media.abapages.com/course-site/chill_sub.wav"

N = 101
cutoff_hz = 800.0
frac = 7   # number of fractional bits, must be <= 7 for signed int8
scale = 1 << frac

os.makedirs("data", exist_ok=True)

if not os.path.isfile(input_file):
    print(f"{input_file} not found. Downloading from {download_url} ...")
    req = urllib.request.Request(
        download_url, headers={"User-Agent": "Mozilla/5.0", "Accept": "*/*"})
    with urllib.request.urlopen(req) as response, open(input_file, "wb") as f:
        f.write(response.read())

'''
Process input
'''
fs, x = wavfile.read(input_file)
x = x.astype(np.float32)

if x.ndim > 1:
    x = np.mean(x, axis=1) # Convert to mono

# Quantize input to int8 fixed-point
x_q = np.clip(np.round(x * scale), -128, 127).astype(np.int8)
np.savetxt("data/x_music.txt", x_q, fmt='%d')

'''
Create FIR Filter
'''
h = firwin(N, cutoff=cutoff_hz, fs=fs, pass_zero="lowpass")
h_q = np.clip(np.round(h * scale), -128, 127).astype(np.int8)

with open("data/coef.svh", "w") as f:
    f.write(",\n".join(f"  8'd{int(np.uint8(v))}" for v in h_q))

'''
Apply FIR Filter
'''
delay = np.zeros(N, dtype=np.int32)
h32 = h_q.astype(np.int32)
y_q = np.zeros(len(x_q), dtype=np.int8)

for n in range(len(x_q)):
    delay[1:] = delay[:-1]
    delay[0] = np.int32(x_q[n])

    acc = np.sum(delay * h32)            # Qfrac * Qfrac = Q(2*frac)
    y = np.clip(acc >> frac, -128, 127)  # back to Qfrac
    y_q[n] = np.int8(y)

np.savetxt("data/y_exp.txt", y_q, fmt='%d')

'''
Convert to WAV and save
'''
y_f = y_q.astype(np.float32) / scale
y_u8 = np.clip(np.round(y_f * 128.0 + 128.0), 0, 255).astype(np.uint8)

wavfile.write(output_file, fs, y_u8)

print(f"Saved: {output_file}")
plot_filter_response(x_q, h_q, fs, scale, cutoff_hz)
