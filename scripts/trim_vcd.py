#!/usr/bin/env python3
"""Trim a VCD file to a maximum simulated time."""

from __future__ import annotations

import argparse
import re
import sys
from pathlib import Path

TIMESCALE_UNITS = {
    "s": 1_000_000_000_000,
    "ms": 1_000_000_000,
    "us": 1_000_000,
    "ns": 1_000,
    "ps": 1,
    "fs": 0.001,
}


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser()
    parser.add_argument("vcd", help="Path to the VCD file to trim in place")
    parser.add_argument(
        "--end",
        required=True,
        help="Maximum simulated time to keep, e.g. 500ns or 2us",
    )
    return parser.parse_args()


def parse_limit_to_ps(limit: str) -> int:
    match = re.fullmatch(r"\s*(\d+)\s*(s|ms|us|ns|ps|fs)\s*", limit)
    if not match:
        raise ValueError(f"Unsupported time limit {limit!r}")
    value = int(match.group(1))
    unit = match.group(2)
    scale = TIMESCALE_UNITS[unit]
    total_ps = value * scale
    if int(total_ps) != total_ps:
        raise ValueError(f"Time limit {limit!r} is finer than 1ps resolution")
    return int(total_ps)


def extract_timescale_ps(text: str) -> int:
    match = re.search(
        r"\$timescale\b(?P<body>.*?)\$end",
        text,
        re.MULTILINE | re.DOTALL,
    )
    if not match:
        raise ValueError("Could not find $timescale in VCD header")

    body = match.group("body")
    body_match = re.search(r"(\d+)\s*(s|ms|us|ns|ps|fs)\b", body)
    if not body_match:
        raise ValueError("Could not parse VCD $timescale value")

    value = int(body_match.group(1))
    unit = body_match.group(2)
    scale = TIMESCALE_UNITS[unit]
    total_ps = value * scale
    if int(total_ps) != total_ps:
        raise ValueError("VCD timescale is finer than 1ps resolution")
    return int(total_ps)


def main() -> int:
    args = parse_args()
    vcd_path = Path(args.vcd)
    original = vcd_path.read_text(encoding="utf-8", errors="replace")
    end_limit_ps = parse_limit_to_ps(args.end)
    timescale_ps = extract_timescale_ps(original)
    end_limit_ticks = end_limit_ps // timescale_ps

    lines = original.splitlines(keepends=True)
    out_lines: list[str] = []
    current_time: int | None = None
    trimmed = False

    for line in lines:
        if line.startswith("#"):
            try:
                current_time = int(line[1:].strip())
            except ValueError:
                current_time = None
            if current_time is not None and current_time > end_limit_ticks:
                trimmed = True
                break
        out_lines.append(line)

    if trimmed:
        vcd_path.write_text("".join(out_lines), encoding="utf-8")

    print(
        f"{vcd_path}: kept <= {args.end} ({end_limit_ticks} ticks at {timescale_ps} ps/tick)",
        file=sys.stderr,
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
