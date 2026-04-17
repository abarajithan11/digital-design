#!/usr/bin/env python3
"""Convert a VCD file to a WaveDrom-style SVG waveform."""

import argparse
import json
from pathlib import Path

import wavedrom
from vcdvcd import VCDVCD


def _is_unknown(value: str) -> bool:
    v = value.lower()
    return "x" in v or "z" in v


def _bit_char(value: str) -> str:
    v = value.lower()
    if _is_unknown(v):
        return "x"
    return "1" if v.endswith("1") else "0"


def _bus_label(value: str) -> str:
    if _is_unknown(value):
        return "x"
    return format(int(value, 2), "x")


def _sample_values(tv, sample_times):
    idx = 0
    current = str(tv[0][1])
    out = []
    for t in sample_times:
        while idx + 1 < len(tv) and int(tv[idx + 1][0]) <= t:
            idx += 1
            current = str(tv[idx][1])
        out.append(current)
    return out


def _encode_scalar(samples):
    wave = []
    prev = None
    for sample in samples:
        cur = _bit_char(sample)
        if prev is not None and cur == prev:
            wave.append(".")
        else:
            wave.append(cur)
        prev = cur
    return "".join(wave), []


def _encode_bus(samples):
    wave = []
    data = []
    prev = None
    for sample in samples:
        cur = _bus_label(sample)
        if prev is None:
            if cur == "x":
                wave.append("x")
            else:
                wave.append("=")
                data.append(cur)
        elif cur == prev:
            wave.append(".")
        elif cur == "x":
            wave.append("x")
        else:
            wave.append("=")
            data.append(cur)
        prev = cur
    return "".join(wave), data


def main() -> None:
    ap = argparse.ArgumentParser()
    ap.add_argument("--vcd", required=True)
    ap.add_argument("--svg", required=True)
    ap.add_argument("--start", default="auto")
    ap.add_argument("--end", default="auto")
    ap.add_argument("--window", type=int, default=100000)
    ap.add_argument("--sample-rate", type=int, default=256)
    ap.add_argument("--hscale", type=int, default=1)
    ap.add_argument("--max-signals", type=int, default=64)
    args = ap.parse_args()

    vcd = VCDVCD(args.vcd, store_tvs=True)
    signals = [s for s in vcd.signals if getattr(vcd[s], "tv", [])][: args.max_signals]
    if not signals:
        raise RuntimeError("No waveform events found in VCD")

    min_t = min(int(vcd[s].tv[0][0]) for s in signals)
    max_t = max(int(vcd[s].tv[-1][0]) for s in signals)

    start_t = min_t if args.start == "auto" else int(args.start)
    end_t = max_t if args.end == "auto" else int(args.end)
    start_t = max(min_t, start_t)
    end_t = min(max_t, end_t)

    if end_t <= start_t:
        end_t = min(max_t, start_t + max(1, args.window))
    if end_t <= start_t:
        end_t = start_t + 1

    step = max(1, int(args.sample_rate))
    sample_times = list(range(start_t, end_t + 1, step))
    if sample_times[-1] != end_t:
        sample_times.append(end_t)

    wave_signals = []
    for name in signals:
        sig = vcd[name]
        width = int(getattr(sig, "size", 1) or 1)
        tv = [(int(t), str(v)) for t, v in sig.tv]
        if not tv:
            continue
        samples = _sample_values(tv, sample_times)

        if width == 1:
            wave, data = _encode_scalar(samples)
        else:
            wave, data = _encode_bus(samples)

        entry = {"name": name, "wave": wave}
        if data:
            entry["data"] = data
        wave_signals.append(entry)

    source = {
        "signal": wave_signals,
        "config": {"hscale": max(1, int(args.hscale))},
    }

    out = Path(args.svg)
    out.parent.mkdir(parents=True, exist_ok=True)
    svg = wavedrom.render(json.dumps(source))
    svg.saveas(str(out))


if __name__ == "__main__":
    main()