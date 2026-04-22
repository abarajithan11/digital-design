#!/usr/bin/env python3
import numpy as np
import matplotlib.pyplot as plt
from scipy.signal import freqz


def _mag_db(sig, fs):
    spectrum = np.fft.rfft(np.asarray(sig, dtype=np.float32))
    freqs = np.fft.rfftfreq(len(sig), d=1.0 / fs)
    return freqs, 20 * np.log10(np.maximum(np.abs(spectrum), 1e-12))


def _plot_time(ax, t, y, title):
    ax.plot(t, y)
    ax.set(title=title, xlabel="Time (s)", ylabel="Amplitude")
    ax.grid(True)


def _plot_freq(ax, freqs, y_db, title, fs, cutoff_hz=None, add_markers=False):
    ax.semilogx(freqs[1:], y_db[1:])
    if add_markers and cutoff_hz is not None:
        ax.axvline(cutoff_hz, linestyle="--", label=f"Cutoff = {cutoff_hz:.0f} Hz")
        ax.axvline(20, linestyle=":")
        ax.axvline(20000, linestyle=":")
        ax.legend()
    ax.set(
        title=title,
        xlabel="Frequency (Hz)",
        ylabel="Magnitude (dB)",
        xlim=(20, fs / 2),
    )
    ax.grid(True, which="both")


def plot_filter_response(x_q, h_q, fs, scale, cutoff_hz, output_path="data/filter.png"):
    t0 = 0.02
    start_idx = int(t0 * fs)
    n_time = 100

    x_plot = x_q.astype(np.float32) / scale
    h_plot = h_q.astype(np.float32) / scale
    y_plot = np.convolve(x_plot, h_plot, mode="same")

    fx, x_db = _mag_db(x_plot, fs)
    fy, y_db = _mag_db(y_plot, fs)
    fh, h_resp = freqz(h_plot, worN=4096, fs=fs)
    h_resp_db = 20 * np.log10(np.maximum(np.abs(h_resp), 1e-12))

    end_idx = min(start_idx + n_time, len(x_plot), len(y_plot))

    x_seg = x_plot[start_idx:end_idx]
    y_seg = y_plot[start_idx:end_idx]
    tx = np.arange(start_idx, end_idx) / fs
    hf_idx = np.arange(len(h_plot))

    fig, axes = plt.subplots(3, 2, figsize=(14, 10))

    _plot_time(axes[0, 0], tx, x_seg, "Input Signal - Time Domain")
    _plot_freq(axes[0, 1], fx, x_db, "Input Signal - Frequency Domain", fs)

    _plot_time(axes[1, 0], tx, y_seg, "Filtered Signal - Time Domain")
    _plot_freq(axes[1, 1], fy, y_db, "Filtered Signal - Frequency Domain", fs)

    axes[2, 0].stem(hf_idx, h_plot, basefmt=" ")
    axes[2, 0].set(title="FIR Filter - Time Domain", xlabel="Sample", ylabel="Amplitude")
    axes[2, 0].grid(True)

    _plot_freq(
        axes[2, 1],
        fh,
        h_resp_db,
        "FIR Filter - Frequency Domain",
        fs,
        cutoff_hz=cutoff_hz,
        add_markers=True,
    )

    plt.tight_layout()
    plt.savefig(output_path, dpi=200, bbox_inches="tight")
    plt.close(fig)
