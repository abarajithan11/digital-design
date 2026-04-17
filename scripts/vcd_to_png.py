#!/usr/bin/env python3
"""Convert a VCD file to a readable waveform PNG."""

import argparse
from pathlib import Path

import matplotlib

matplotlib.use("Agg")
import matplotlib.pyplot as plt
from vcdvcd import VCDVCD


def to_level(value: str) -> float:
    v = value.lower()
    if "x" in v or "z" in v:
        return 0.5
    if len(v) == 1:
        return 1.0 if v == "1" else 0.0
    return 1.0 if int(v, 2) != 0 else 0.0


def main() -> None:
    ap = argparse.ArgumentParser()
    ap.add_argument("--vcd", required=True)
    ap.add_argument("--png", required=True)
    ap.add_argument("--start", default="auto")
    ap.add_argument("--end", default="auto")
    ap.add_argument("--window", type=int, default=100000)
    ap.add_argument("--max-signals", type=int, default=64)
    args = ap.parse_args()

    vcd = VCDVCD(args.vcd, store_tvs=True)
    signals = [s for s in vcd.signals if getattr(vcd[s], "tv", [])][: args.max_signals]
    if not signals:
        raise RuntimeError("No waveform events found in VCD")

    min_t = min(int(vcd[s].tv[0][0]) for s in signals)
    max_t = max(int(vcd[s].tv[-1][0]) for s in signals)
    start_t = min_t if args.start == "auto" else int(args.start)
    end_t = (start_t + args.window) if args.end == "auto" else int(args.end)
    start_t = max(min_t, start_t)
    end_t = min(max_t, end_t)
    if end_t <= start_t:
        end_t = min(max_t, start_t + max(1, args.window))
    if end_t <= start_t:
        end_t = start_t + 1

    fig_h = max(3.0, 0.45 * len(signals) + 1.5)
    fig, ax = plt.subplots(figsize=(14, fig_h), dpi=160)

    for i, name in enumerate(signals):
        base = (len(signals) - 1 - i) * 1.2
        tv = [(int(t), str(v)) for t, v in vcd[name].tv]

        current = tv[0][1]
        for t, v in tv:
            if t <= start_t:
                current = v
            else:
                break

        xs = [start_t]
        ys = [base + 0.8 * to_level(current)]
        for t, v in tv:
            if start_t <= t <= end_t:
                xs.append(t)
                ys.append(base + 0.8 * to_level(v))
        xs.append(end_t)
        ys.append(ys[-1])
        ax.plot(xs, ys, drawstyle="steps-post", linewidth=1.2)

    ax.set_yticks([(len(signals) - 1 - i) * 1.2 + 0.4 for i in range(len(signals))])
    ax.set_yticklabels(signals, fontsize=8)
    ax.set_xlim(start_t, end_t)
    ax.set_xlabel("Time (sim ticks)")
    ax.set_title(f"Waveform: {Path(args.vcd).name}")
    ax.grid(True, axis="x", linestyle=":", alpha=0.35)
    fig.tight_layout()

    out = Path(args.png)
    out.parent.mkdir(parents=True, exist_ok=True)
    fig.savefig(out)
    plt.close(fig)


if __name__ == "__main__":
    main()
