#!/usr/bin/env python3
import os
import urllib.request
import numpy as np
from scipy.signal import firwin, freqz
from scipy.io import wavfile
import matplotlib.pyplot as plt

input_file = "data/chill_sub.wav"
output_file = "data/bass_only_8bit.wav"
download_url = "https://github.com/abarajithan11/digital-design-content/raw/main/chill_sub.wav"

N = 101
cutoff_hz = 800.0
frac = 7   # number of fractional bits, must be <= 7 for signed int8
scale = 1 << frac

os.makedirs("data", exist_ok=True)

if not os.path.isfile(input_file):
    print(f"{input_file} not found. Downloading from {download_url} ...")
    urllib.request.urlretrieve(download_url, input_file)

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

'''
Plotting the time and frequency response
'''

t0 = 0.02
start_idx = int(t0 * fs)
n_time = 100

x_plot = x_q.astype(np.float32) / scale
h_plot = h_q.astype(np.float32) / scale
y_plot = np.convolve(x_plot, h_plot, mode="same")

def mag_db(sig):
    S = np.fft.rfft(np.asarray(sig, dtype=np.float32))
    f = np.fft.rfftfreq(len(sig), d=1.0 / fs)
    return f, 20 * np.log10(np.maximum(np.abs(S), 1e-12))

def plot_time(ax, t, y, title):
    ax.plot(t, y)
    ax.set(title=title, xlabel="Time (s)", ylabel="Amplitude")
    ax.grid(True)

def plot_freq(ax, f, y_db, title, add_markers=False):
    ax.semilogx(f[1:], y_db[1:])
    if add_markers:
        ax.axvline(cutoff_hz, linestyle="--", label=f"Cutoff = {cutoff_hz:.0f} Hz")
        ax.axvline(20, linestyle=":")
        ax.axvline(20000, linestyle=":")
        ax.legend()
    ax.set(title=title, xlabel="Frequency (Hz)", ylabel="Magnitude (dB)", xlim=(20, fs / 2))
    ax.grid(True, which="both")

fx, X_db = mag_db(x_plot)
fy, Y_db = mag_db(y_plot)
fh, H = freqz(h_plot, worN=4096, fs=fs)
H_db = 20 * np.log10(np.maximum(np.abs(H), 1e-12))

end_idx = min(start_idx + n_time, len(x_plot), len(y_plot))

x_seg = x_plot[start_idx:end_idx]
y_seg = y_plot[start_idx:end_idx]
tx = np.arange(start_idx, end_idx) / fs

# Filter time-domain uses sample index
hf_idx = np.arange(len(h_plot))

fig, axes = plt.subplots(3, 2, figsize=(14, 10))

plot_time(axes[0, 0], tx, x_seg, "Input Signal - Time Domain")
plot_freq(axes[0, 1], fx, X_db, "Input Signal - Frequency Domain")

plot_time(axes[1, 0], tx, y_seg, "Filtered Signal - Time Domain")
plot_freq(axes[1, 1], fy, Y_db, "Filtered Signal - Frequency Domain")

axes[2, 0].stem(hf_idx, h_plot, basefmt=" ")
axes[2, 0].set(title="FIR Filter - Time Domain", xlabel="Sample", ylabel="Amplitude")
axes[2, 0].grid(True)

plot_freq(axes[2, 1], fh, H_db, "FIR Filter - Frequency Domain", add_markers=True)

plt.tight_layout()
plt.savefig("data/filter.png", dpi=200, bbox_inches="tight")
plt.close(fig)