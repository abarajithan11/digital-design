#!/usr/bin/env python3
"""Convert an OpenSCAD file into a normalized GLB while preserving SCAD colors."""

from __future__ import annotations

import argparse
import re
import shutil
import subprocess
import tempfile
from collections import OrderedDict
from pathlib import Path

import numpy as np
import trimesh


COLOR_RE = re.compile(
    r"color\s*\(\s*alpha\s*=\s*([0-9eE.+-]+)\s*,\s*c\s*=\s*\[([^\]]+)\]",
    re.MULTILINE,
)


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(
        description="Export a color-preserving .glb from a .scad file."
    )
    parser.add_argument("src", type=Path, help="Path to the source .scad file")
    parser.add_argument("dst", type=Path, help="Path to the output .glb file")
    parser.add_argument(
        "--openscad",
        default="openscad",
        help="OpenSCAD executable to use",
    )
    return parser


def find_matching_brace(text: str, start: int) -> int:
    depth = 0
    for index in range(start, len(text)):
        char = text[index]
        if char == "{":
            depth += 1
        elif char == "}":
            depth -= 1
            if depth == 0:
                return index
    raise ValueError("Unbalanced braces in SCAD input")


def extract_union_sections(text: str) -> tuple[str, str, list[str]]:
    union_index = text.find("union()")
    if union_index < 0:
        raise ValueError("Could not find top-level union() in SCAD input")

    union_open = text.find("{", union_index)
    if union_open < 0:
        raise ValueError("Could not find opening brace for top-level union()")

    union_close = find_matching_brace(text, union_open)
    prefix = text[: union_open + 1]
    body = text[union_open + 1 : union_close]
    suffix = text[union_close:]
    return prefix, suffix, split_top_level_blocks(body)


def split_top_level_blocks(body: str) -> list[str]:
    blocks: list[str] = []
    index = 0
    length = len(body)

    while index < length:
        while index < length and body[index].isspace():
            index += 1
        if index >= length:
            break

        start = index
        brace_open = body.find("{", start)
        if brace_open < 0:
            raise ValueError("Encountered top-level SCAD content without a block")

        brace_close = find_matching_brace(body, brace_open)
        blocks.append(body[start : brace_close + 1].strip())
        index = brace_close + 1

    return blocks


def parse_color(block: str) -> tuple[float, float, float, float]:
    match = COLOR_RE.search(block)
    if not match:
        raise ValueError("Could not parse color() block header")

    alpha = float(match.group(1))
    rgb = tuple(float(component.strip()) for component in match.group(2).split(","))
    if len(rgb) != 3:
        raise ValueError("Expected RGB triplet in color() block")
    return (rgb[0], rgb[1], rgb[2], alpha)


def color_to_rgba(color: tuple[float, float, float, float]) -> np.ndarray:
    rgba = np.array(
        [round(channel * 255) for channel in color[:3]] + [round(color[3] * 255)],
        dtype=np.uint8,
    )
    return rgba


def export_color_meshes(
    prefix: str,
    suffix: str,
    grouped_blocks: OrderedDict[tuple[float, float, float, float], list[str]],
    openscad: str,
    tmpdir: str,
) -> list[tuple[str, trimesh.Trimesh, np.ndarray]]:
    meshes: list[tuple[str, trimesh.Trimesh, np.ndarray]] = []

    for index, (color, blocks) in enumerate(grouped_blocks.items()):
        scad_path = Path(tmpdir) / f"layer_{index:02d}.scad"
        stl_path = Path(tmpdir) / f"layer_{index:02d}.stl"
        scad_path.write_text(prefix + "\n" + "\n".join(blocks) + "\n" + suffix)

        subprocess.run(
            [openscad, "-o", str(stl_path), str(scad_path)],
            check=True,
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL,
        )

        mesh = trimesh.load(stl_path, force="mesh")
        mesh.visual.face_colors = np.tile(color_to_rgba(color), (len(mesh.faces), 1))
        meshes.append((f"layer_{index:02d}", mesh, color_to_rgba(color)))

    return meshes


def normalize_scene(scene: trimesh.Scene) -> trimesh.Scene:
    bounds = scene.bounds
    centroid = (bounds[0] + bounds[1]) / 2.0
    extents = bounds[1] - bounds[0]
    max_extent = float(np.max(extents))

    transform = np.eye(4)
    transform[:3, 3] = -centroid
    scene.apply_transform(transform)

    if max_extent > 0:
        scale = np.eye(4)
        scale[0, 0] = scale[1, 1] = scale[2, 2] = 1.0 / max_extent
        scene.apply_transform(scale)

    return scene


def main() -> int:
    args = build_parser().parse_args()
    src = args.src.resolve()
    dst = args.dst.resolve()

    if not src.is_file():
        raise FileNotFoundError(f"SCAD file not found: {src}")

    openscad = shutil.which(args.openscad)
    if not openscad:
        raise FileNotFoundError(f"OpenSCAD executable not found: {args.openscad}")

    prefix, suffix, blocks = extract_union_sections(src.read_text())
    grouped_blocks: OrderedDict[tuple[float, float, float, float], list[str]] = OrderedDict()
    for block in blocks:
        color = parse_color(block)
        grouped_blocks.setdefault(color, []).append(block)

    dst.parent.mkdir(parents=True, exist_ok=True)

    with tempfile.TemporaryDirectory(prefix="scad-to-glb-") as tmpdir:
        color_meshes = export_color_meshes(
            prefix=prefix,
            suffix=suffix,
            grouped_blocks=grouped_blocks,
            openscad=openscad,
            tmpdir=tmpdir,
        )

        scene = trimesh.Scene()
        for name, mesh, _rgba in color_meshes:
            scene.add_geometry(mesh, node_name=name, geom_name=name)

        normalize_scene(scene)
        dst.write_bytes(scene.export(file_type="glb"))

    print(f"Wrote {dst} with {len(grouped_blocks)} color groups")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
