#!/usr/bin/env python3
import os
import urllib.request
import numpy as np
from scipy.signal import remez
from scipy.io import wavfile

from plot_filter import plot_filter_response

input_file = "data/chill_sub.wav"
output_file = "data/bass_only_8bit.wav"
download_url = "https://media.abapages.com/course-site/chill_sub.wav"

N = 101
cutoff_hz = 250.0
transition_hz = 1200.0
stop_weight = 25    # stopband error weight; buys attenuation for tiny ripple
K_BITS = 8
X_FRAC = 7
K_FRAC = 11
x_scale = 1 << X_FRAC
k_scale = 1 << K_FRAC

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
x_q = np.clip(np.round(x * x_scale), -128, 127).astype(np.int8)
np.savetxt("data/x_music.txt", x_q, fmt='%d')

'''
Create FIR Filter
'''
bands = [0.0, cutoff_hz, cutoff_hz + transition_hz, fs / 2]

h = remez(N, bands, desired=[1, 0], weight=[1, stop_weight], fs=fs)

# Check the range BEFORE casting: .astype(np.int8) wraps silently, so testing
# afterwards can never see a coefficient that overflowed.
K_MAX = 2**(K_BITS-1) - 1     # int8: +127, not +128
K_MIN = -2**(K_BITS-1)
h_f = np.round(h * k_scale)
exceeded = h_f[(h_f < K_MIN) | (h_f > K_MAX)]
if exceeded.size > 0:
    print(f"WARNING: {exceeded.size} coeff outside {K_BITS}-bits, clipping "
          f"(lower K_FRAC): {exceeded.tolist()}")
h_q = np.clip(h_f, K_MIN, K_MAX).astype(np.int8)

with open("data/coef.svh", "w") as f:
    f.write(",\n".join(f"{'-' if v < 0 else ''}{K_BITS}'d{abs(int(v))}" for v in h_q))

'''
Apply FIR Filter
'''
delay = np.zeros(N, dtype=np.int32)
h32 = h_q.astype(np.int32)
y_q = np.zeros(len(x_q), dtype=np.int8)

for n in range(len(x_q)):
    delay[1:] = delay[:-1]
    delay[0] = np.int32(x_q[n])

    acc = np.sum(delay * h32)              # Q(X_FRAC) * Q(K_FRAC)
    y = np.clip(acc >> K_FRAC, -128, 127)  # undo the coefficient scale -> Q(X_FRAC)
    y_q[n] = np.int8(y)

np.savetxt("data/y_exp.txt", y_q, fmt='%d')

'''
Convert to WAV and save
'''
y_f = y_q.astype(np.float32) / x_scale
y_u8 = np.clip(np.round(y_f * 128.0 + 128.0), 0, 255).astype(np.uint8)

wavfile.write(output_file, fs, y_u8)

print(f"Saved: {output_file}")
plot_filter_response(x_q, h_q, fs, k_scale, cutoff_hz)
