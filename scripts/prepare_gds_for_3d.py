#!/usr/bin/env python3
"""Prepare a lower-detail GDS for responsive whole-chip 3D previews."""

from __future__ import annotations

import argparse
from pathlib import Path

import klayout.db as kdb


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser()
    parser.add_argument("src", type=Path)
    parser.add_argument("dst", type=Path)
    parser.add_argument("--cell", required=True)
    parser.add_argument("--exclude-layer", action="append", default=[])
    return parser


def main() -> int:
    args = build_parser().parse_args()
    layout = kdb.Layout()
    layout.read(str(args.src))

    cell = layout.cell(args.cell)
    if cell is None:
        raise ValueError(f"Cell {args.cell!r} not found in {args.src}")

    excluded_layers = {
        tuple(int(part) for part in layer.split("/", 1))
        for layer in args.exclude_layer
    }

    cell.flatten(True)
    for layer_index in layout.layer_indexes():
        info = layout.get_info(layer_index)
        if (info.layer, info.datatype) in excluded_layers:
            cell.shapes(layer_index).clear()
            continue
        merged = kdb.Region(cell.begin_shapes_rec(layer_index))
        if merged.is_empty():
            continue
        merged.merge()
        cell.shapes(layer_index).clear()
        cell.shapes(layer_index).insert(merged)

    args.dst.parent.mkdir(parents=True, exist_ok=True)
    layout.write(str(args.dst))
    print(f"Wrote merged GDS: {args.dst}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
