#!/usr/bin/env python3
"""Generate docs/design_outputs.md from existing simulation and layout artifacts."""
from __future__ import annotations

from pathlib import Path
import shutil

LAYOUT_IMAGES = [
    "final_routing.webp",
    "final_placement.webp",
    "final_worst_path.webp",
]
DOWNLOADABLE_ASSETS = [
    ("VCD", "{design_name}.vcd"),
    ("SVG", "{design_name}_short.svg"),
    ("GDS", "{design_name}.gds"),
    ("GDS Logs", "logs.zip"),
]

REPO_URL = "https://github.com/abarajithan11/digital-design"
ROOT_MAT = "https://github.com/abarajithan11/digital-design/blob/main/material"

DESIGNS = [
    # {"design_name": "not_gate", "description": "Not Gate"},
    {"design_name": "full_adder", "description": "1-bit Full Adder"},
    {"design_name": "n_adder", "description": "N-bit Ripple Carry Adder"},
    {"design_name": "alu", "description": "ALU"},
    # {"design_name": "flip_flop", "description": "Flip Flop"},
    {"design_name": "up_counter", "description": "Up Counter"},
    {
        "design_name": "reduction_tree_min",
        "description": "Binary Reduction Tree",
    },
    {
        "design_name": "parallel_to_serial",
        "description": "AXI-Stream Parallel to Serial Converter",
    },
    {"design_name": "down_counter", "description": "Down Counter (Chainable)"},
    {"design_name": "uart_rx", "description": "UART RX"},
    {"design_name": "uart_tx", "description": "UART TX"},
    {
        "design_name": "uart_echo",
        "description": "UART Echo (RX + TX) System",
    },
    {
        "design_name": "fir_filter",
        "description": f"FIR Filter [[Naive RTL]({ROOT_MAT}/rtl/fir_filter_naive.sv)]",
    },
    {
        "design_name": "sys_fir_filter",
        "description": f"System: 100-tap FIR Filter via UART [[Python filter]({ROOT_MAT}/py/sys_fir_filter_gen.py)]",
    },
]
STATIC_GLB_ASSETS = [
    ("out/gds-assets/n_adder/n_adder.glb", "n_adder.glb"),
    ("out/gds-assets/cell_3d/INVx1_ASAP7_75t_R.glb", "INVx1_ASAP7_75t_R.glb"),
    ("out/gds-assets/cell_3d/NAND2x1_ASAP7_75t_R.glb", "NAND2x1_ASAP7_75t_R.glb"),
    ("out/gds-assets/cell_3d/AOI211x1_ASAP7_75t_R.glb", "AOI211x1_ASAP7_75t_R.glb"),
    ("out/gds-assets/cell_3d/DFFHQNx1_ASAP7_75t_R.glb", "DFFHQNx1_ASAP7_75t_R.glb"),
]


def build_design_entry(index: int, design_meta: dict, repo: Path) -> dict:
    """Return metadata for a design from the explicit design list."""
    design_name = design_meta["design_name"]
    flist_path = repo / "material" / "designs" / f"{design_name}.f"
    flist_lines = [
        line.strip()
        for line in flist_path.read_text(encoding="utf-8").splitlines()
        if line.strip() and not line.lstrip().startswith("#")
    ]
    rtl_files = [line for line in flist_lines if line.startswith("rtl/")]
    tb_files = [line for line in flist_lines if line.startswith("tb/")]

    return {
        **design_meta,
        "index": index,
        "heading": f'{index}. {design_meta["description"]}',
        "slug": design_name.replace("_", "-"),
        "flist_rel": f"material/designs/{design_name}.f",
        "top_rtl_rel": f"material/{rtl_files[0]}" if rtl_files else None,
        "top_tb_rel": f"material/{tb_files[0]}" if tb_files else None,
    }


def first_existing_path(*candidates: Path | None) -> Path | None:
    """Return the first existing path from candidates."""
    for candidate in candidates:
        if candidate is not None and candidate.exists():
            return candidate
    return None


def first_existing_text_file(*candidates: Path | None) -> Path | None:
    """Return the first existing regular file from candidates."""
    for candidate in candidates:
        if candidate is not None and candidate.is_file():
            return candidate
    return None


def downloadable_asset_source(
    repo: Path,
    design_name: str,
    filename: str,
    deployed_dir: Path | None = None,
) -> Path | None:
    """Return the best available source for a downloadable asset."""
    gds_result = (
        repo / "material" / "openroad" / "work" / "results" / "asap7" / design_name / "base" / "6_final.gds"
        if filename.endswith(".gds")
        else None
    )
    return first_existing_path(
        repo / "out" / "sim-assets" / design_name / filename,
        repo / "sim-assets" / design_name / filename,
        repo / "material" / "sim" / design_name / filename,
        repo / "out" / "gds-assets" / design_name / filename,
        gds_result,
        (deployed_dir / filename) if deployed_dir is not None else None,
    )


def sync_static_assets(repo: Path) -> None:
    """Stage downloadable and GLB assets under docs/_static before the site build."""
    design_outputs_root = repo / "docs" / "_static" / "design-outputs"
    design_outputs_root.mkdir(parents=True, exist_ok=True)

    for design_meta in DESIGNS:
        design_name = design_meta["design_name"]
        dst = design_outputs_root / design_name
        dst.mkdir(parents=True, exist_ok=True)

        for _, filename_tmpl in DOWNLOADABLE_ASSETS:
            filename = filename_tmpl.format(design_name=design_name)
            source = downloadable_asset_source(repo, design_name, filename)
            if source is not None:
                shutil.copy2(source, dst / filename)

    docs_static_root = repo / "docs" / "_static"
    docs_static_root.mkdir(parents=True, exist_ok=True)
    for src_rel, dst_name in STATIC_GLB_ASSETS:
        source = repo / src_rel
        destination = docs_static_root / dst_name
        if source.exists():
            shutil.copy2(source, destination)
        elif destination.exists():
            destination.unlink()


def build_markdown(designs_data: list[dict], assets_root: Path) -> list[str]:
    """Return markdown lines for all designs given pre-resolved data."""
    lines = [
        "# Design Examples",
        "",
        "In this course, digital design concepts and SystemVerilog features will be introduced through examples of gradually increasing complexity, inspired by real digital systems, as follows:",
        "",
        "| # | Design | Files | RTL | TB | Results |",
        "|---|---|---|---|---|---|",
    ]

    for d in designs_data:
        flist_link = f"[link]({ROOT_MAT}/designs/{d['design_name']}.f)"
        rtl_link = f"[link]({REPO_URL}/blob/main/{d['top_rtl_rel']})" if d["top_rtl_rel"] else "—"
        tb_link = f"[link]({REPO_URL}/blob/main/{d['top_tb_rel']})" if d["top_tb_rel"] else "—"
        outputs_link = f'<a href="#{d["slug"]}">link</a>'
        lines.append(
            f"| {d['index']} | {d['description']} | {flist_link} | {rtl_link} | {tb_link} | {outputs_link} |"
        )

    lines.extend(
        [
            "",
            "## Waveforms and ASAP7 GDS",
            "",
            "For each design our GitHub Actions flow runs",
            "",
            "1. Simulation using Verilator, generating VCD, converted to SVG,",
            "2. OpenROAD RTL2GDS2 flow using [ASAP7 7nm, a realistic PDK for academic use,](https://www.sciencedirect.com/science/article/pii/S002626921630026X)",
            "",
            "collects their outputs and displays them here.",
            "",
            "To reproduce this on your machine, check out our [docker setup](setting-up-docker.md).",
            "",
            f"* Our repository: [github.com/abarajithan11/digital-design]({REPO_URL})",
            "* Filelists: [material/designs](https://github.com/abarajithan11/digital-design/tree/main/material/designs)",
            "* SystemVerilog RTL: [material/rtl](https://github.com/abarajithan11/digital-design/tree/main/material/rtl)",
            "* Testbenches: [material/tb](https://github.com/abarajithan11/digital-design/tree/main/material/tb)",
            "* Makefile: [material/Makefile](https://github.com/abarajithan11/digital-design/tree/main/material/Makefile)",
            "* OpenRoad Flow: [material/openroad](https://github.com/abarajithan11/digital-design/tree/main/material/openroad)",
            "",
        ]
    )

    for d in designs_data:
        design_name = d["design_name"]
        heading = d["heading"]
        sim_result = d["sim_result"]
        rtl2gds_result = d["rtl2gds_result"]
        dst = assets_root / design_name
        short_svg = dst / f"{design_name}_short.svg"
        artifact_links = [
            f'<a href="_static/design-outputs/{design_name}/{filename}">{label}</a>'
            for label, filename in d["downloadable_assets"]
        ]
        artifact_line = ", ".join(artifact_links) if artifact_links else "Preview assets only"

        lines.extend([f'<a id="{d["slug"]}"></a>', "", f"## {heading}", ""])
        lines.extend(
            [
                "**Run results**",
                "",
                f"- Simulation: {sim_result}, RTL2GDS: {rtl2gds_result}",
                f"- Artifacts : {artifact_line}",
                "",
                "**Layout Reports**",
            ]
        )

        routing_path = f"_static/design-outputs/{design_name}/final_routing.webp"
        placement_path = f"_static/design-outputs/{design_name}/final_placement.webp"
        worst_path = f"_static/design-outputs/{design_name}/final_worst_path.webp"

        if all((dst / img).exists() for img in LAYOUT_IMAGES):
            lines.extend(
                [
                    '<div style="display:grid; grid-template-columns:repeat(auto-fit,minmax(220px,1fr)); gap:12px; max-width:1100px; margin:0 auto;">',
                    f'  <img src="{routing_path}" alt="{design_name} routing" style="width:100%; height:auto; display:block;" />',
                    f'  <img src="{placement_path}" alt="{design_name} placement" style="width:100%; height:auto; display:block;" />',
                    f'  <img src="{worst_path}" alt="{design_name} worst path" style="width:100%; height:auto; display:block;" />',
                    "</div>",
                    '<p style="text-align:center;">Routing, Placement, Worst path</p>',
                    "",
                ]
            )
        else:
            lines.extend(["One or more layout images were not generated.", ""])

        lines.extend(["**Waveform (0-10 ns)**", ""])
        if short_svg.exists():
            waveform_path = f"_static/design-outputs/{design_name}/{design_name}_short.svg"
            lines.extend(
                [
                    f'<div class="waveform-svg" data-svg-src="{waveform_path}" role="img" aria-label="{design_name} waveform">',
                    f'  <a href="{waveform_path}">{design_name} waveform</a>',
                    "</div>",
                ]
            )
        else:
            lines.append("Waveform SVG not generated.")
        lines.append("")

    return lines


def generate_outputs(repo: Path) -> None:
    """Assemble markdown from pre-built local or CI-downloaded artifacts."""
    docs_md = repo / "docs" / "design_outputs.md"
    assets_root = repo / "docs" / "_static" / "design-outputs"
    sim_out_assets_roots = [
        repo / "out" / "sim-assets",
        repo / "sim-assets",
    ]
    sim_assets_root = repo / "material" / "sim"
    local_gds_assets_root = repo / "material" / "openroad" / "work" / "reports" / "asap7"
    gds_assets_root = repo / "out" / "gds-assets"
    deployed_assets_root = repo / "site" / "_static" / "design-outputs"

    if assets_root.exists():
        shutil.rmtree(assets_root)
    assets_root.mkdir(parents=True, exist_ok=True)

    sim_statuses: dict[str, str] = {}
    status_file = first_existing_text_file(
        repo / "out" / "sim" / "status.tsv",
        repo / "sim" / "status.tsv",
    )
    if status_file is not None:
        for row in status_file.read_text(encoding="utf-8").splitlines():
            if row.strip():
                name, status = row.split("\t", maxsplit=1)
                sim_statuses[name] = status.strip()

    configured_designs = [design_meta["design_name"] for design_meta in DESIGNS]
    discovered_designs = sorted(path.stem for path in (repo / "material" / "designs").glob("*.f"))
    missing_from_tree = sorted(set(configured_designs) - set(discovered_designs))
    if missing_from_tree:
        print("\nConfigured designs are missing from material/designs: " + ", ".join(missing_from_tree))

    design_entries = [build_design_entry(index, design_meta, repo) for index, design_meta in enumerate(DESIGNS, start=1)]

    if not design_entries:
        docs_md.write_text(
            "# Design Examples\n\nNo designs configured in scripts/generate_outputs.py.\n",
            encoding="utf-8",
        )
        return

    designs_data = []
    for entry in design_entries:
        design_name = entry["design_name"]
        dst = assets_root / design_name
        dst.mkdir(parents=True, exist_ok=True)
        deployed_dir = deployed_assets_root / design_name
        downloadable_assets: list[tuple[str, str]] = []

        sim_svg_short = first_existing_path(
            *[
                root / design_name / f"{design_name}_short.svg"
                for root in sim_out_assets_roots
            ],
            sim_assets_root / design_name / f"{design_name}_short.svg",
            deployed_dir / f"{design_name}_short.svg",
        )
        if sim_svg_short is not None:
            shutil.copy2(sim_svg_short, dst / f"{design_name}_short.svg")

        for label, filename_tmpl in DOWNLOADABLE_ASSETS:
            filename = filename_tmpl.format(design_name=design_name)
            source_path = downloadable_asset_source(repo, design_name, filename, deployed_dir)
            if source_path is not None:
                downloadable_assets.append((label, filename))

        local_reports_dir = local_gds_assets_root / design_name / "base"

        for image in LAYOUT_IMAGES:
            source_image = local_reports_dir / image
            if not source_image.exists():
                source_image = gds_assets_root / design_name / image
            if not source_image.exists():
                matches = list(gds_assets_root.glob(f"**/{design_name}/{image}"))
                if matches:
                    source_image = matches[0]
            if not source_image.exists():
                source_image = deployed_dir / image
            if source_image.exists():
                shutil.copy2(source_image, dst / image)

        raw_status = sim_statuses.get(design_name)
        per_design_sim_status = first_existing_text_file(
            repo / "out" / "sim" / f"{design_name}.status",
            repo / "sim" / f"{design_name}.status",
        )
        if raw_status is None and per_design_sim_status is not None:
            raw_status = per_design_sim_status.read_text(encoding="utf-8").strip()
        if raw_status is None:
            raw_status = "pass" if sim_svg_short is not None else "unknown"

        gds_status_file = gds_assets_root / design_name / "status.txt"
        if gds_status_file.exists():
            rtl2gds_result = "passed" if gds_status_file.read_text(encoding="utf-8").strip() == "pass" else "failed"
        else:
            rtl2gds_result = "passed" if (dst / "final_routing.webp").exists() else "failed"

        designs_data.append(
            {
                **entry,
                "downloadable_assets": downloadable_assets,
                "sim_result": "passed" if raw_status == "pass" else raw_status,
                "rtl2gds_result": rtl2gds_result,
            }
        )

    lines = build_markdown(designs_data, assets_root)
    docs_md.write_text("\n".join(lines) + "\n", encoding="utf-8")
    sync_static_assets(repo)


def main() -> None:
    repo = Path(__file__).resolve().parents[1]
    generate_outputs(repo)


if __name__ == "__main__":
    main()
