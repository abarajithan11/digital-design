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
    ("VCD", "{design_numbered}.vcd")
]
STATIC_GLB_ASSETS = [
    ("out/gds-assets/3_n_adder/n_adder.glb", "n_adder.glb"),
    ("out/gds-assets/cell_3d/INVx1_ASAP7_75t_R.glb", "INVx1_ASAP7_75t_R.glb"),
    ("out/gds-assets/cell_3d/NAND2x1_ASAP7_75t_R.glb", "NAND2x1_ASAP7_75t_R.glb"),
    ("out/gds-assets/cell_3d/DFFHQNx1_ASAP7_75t_R.glb", "DFFHQNx1_ASAP7_75t_R.glb"),
]

REPO_URL = "https://github.com/abarajithan11/digital-design"
ROOT_MAT = "https://github.com/abarajithan11/digital-design/blob/main/material"


def parse_design_entry(design_numbered: str, repo: Path) -> dict:
    """Return metadata for a numbered design filelist stem."""
    flist_path = repo / "material" / "designs" / f"{design_numbered}.f"
    flist_lines = [line.strip() for line in flist_path.read_text(encoding="utf-8").splitlines() if line.strip()]
    rtl_files = [line for line in flist_lines if line.startswith("rtl/")]
    tb_files = [line for line in flist_lines if line.startswith("tb/")]

    number, design_base = design_numbered.split("_", 1)
    display_name = design_base.replace("_", " ").title()
    heading = f"{number}. {display_name}"

    return {
        "design_numbered": design_numbered,
        "design_base": design_base,
        "heading": heading,
        "flist_rel": f"material/designs/{design_numbered}.f",
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


def downloadable_asset_source(repo: Path, design_numbered: str, filename: str, deployed_dir: Path | None = None) -> Path | None:
    """Return the best available source for a downloadable asset."""
    return first_existing_path(
        repo / "out" / "sim-assets" / design_numbered / filename,
        repo / "sim-assets" / design_numbered / filename,
        repo / "material" / "sim" / design_numbered / filename,
        repo / "out" / "gds-assets" / design_numbered / filename,
        (deployed_dir / filename) if deployed_dir is not None else None,
    )


def sync_static_assets(repo: Path) -> None:
    """Stage downloadable and GLB assets under docs/_static before the site build."""
    design_outputs_root = repo / "docs" / "_static" / "design-outputs"
    design_outputs_root.mkdir(parents=True, exist_ok=True)

    for flist in sorted((repo / "material" / "designs").glob("*.f"), key=lambda p: int(p.stem.split("_", 1)[0])):
        design_numbered = flist.stem
        dst = design_outputs_root / design_numbered
        dst.mkdir(parents=True, exist_ok=True)

        for _, filename_tmpl in DOWNLOADABLE_ASSETS:
            filename = filename_tmpl.format(design_numbered=design_numbered)
            source = downloadable_asset_source(repo, design_numbered, filename)
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
    lines = f"""# Design Examples

In this course, digital design concepts and SystemVerilog features will be introduced through examples of gradually increasing complexity, inspired by real digital systems, as follows:

| # | Design | File List | RTL | TB | Outputs |
|---|---|---|---|---|---|
| 1 | Not Gate | [link]({ROOT_MAT}/designs/1_not_gate.f) | [link]({ROOT_MAT}/rtl/not_gate.sv) | [link]({ROOT_MAT}/tb/tb_not_gate.sv) | [link](not-gate) |
| 2 | Full Adder | [link]({ROOT_MAT}/designs/2_full_adder.f) | [link]({ROOT_MAT}/rtl/full_adder.sv) | [link]({ROOT_MAT}/tb/tb_full_adder.sv) | [link](full-adder) |
| 3 | N-Adder | [link]({ROOT_MAT}/designs/3_n_adder.f) | [link]({ROOT_MAT}/rtl/n_adder.sv) | [link]({ROOT_MAT}/tb/tb_n_adder.sv) | [link](n-adder) |
| 4 | ALU | [link]({ROOT_MAT}/designs/4_alu.f) | [link]({ROOT_MAT}/rtl/alu.sv) | [link]({ROOT_MAT}/tb/tb_alu.sv) | [link](alu) |
| 5 | Encoder | — | — | — | — |
| 6 | Decoder | — | — | — | — |
| 7 | Verilog Functions | — | — | — | — |
| 8 | Flip Flop | [link]({ROOT_MAT}/designs/8_flip_flop.f) | [link]({ROOT_MAT}/rtl/flip_flop.sv) | [link]({ROOT_MAT}/tb/tb_flip_flop.sv) | [link](flip-flop) |
| 9 | Up counter | [link]({ROOT_MAT}/designs/9_up_counter.f) | [link]({ROOT_MAT}/rtl/up_counter.sv) | [link]({ROOT_MAT}/tb/tb_up_counter.sv) | [link](up-counter) |
| 10 | Binary Reduction Tree | [link]({ROOT_MAT}/designs/10_reduction_tree_min.f) | [link]({ROOT_MAT}/rtl/reduction_tree_min.sv) | [link]({ROOT_MAT}/tb/tb_reduction_tree_min.sv) | [link](reduction-tree-min) |
| 11 | Parallel to Serial Converter | [link]({ROOT_MAT}/designs/11_parallel_to_serial.f) | [link]({ROOT_MAT}/rtl/parallel_to_serial.sv) | [link]({ROOT_MAT}/tb/tb_parallel_to_serial.sv) | [link](parallel-to-serial) |
| 12 | Down counter | [link]({ROOT_MAT}/designs/12_down_counter.f) | [link]({ROOT_MAT}/rtl/down_counter.sv) | [link]({ROOT_MAT}/tb/tb_down_counter.sv) | [link](down-counter) |
| 13 | UART RX | [link]({ROOT_MAT}/designs/13_uart_rx.f) | [link]({ROOT_MAT}/rtl/uart_rx.sv) | [link]({ROOT_MAT}/tb/tb_uart_rx.sv) | [link](uart-rx) |
| 14 | UART TX | [link]({ROOT_MAT}/designs/14_uart_tx.f) | [link]({ROOT_MAT}/rtl/uart_tx.sv) | [link]({ROOT_MAT}/tb/tb_uart_tx.sv) | [link](uart-tx) |
| 15 | UART Echo (RX + TX) | [link]({ROOT_MAT}/designs/15_uart_echo.f) | [link]({ROOT_MAT}/rtl/uart_echo.v) | [link]({ROOT_MAT}/tb/tb_uart_echo.sv) | [link](uart-echo) |
| 16 | FIR Filter [Retimed RTL]({ROOT_MAT}/rtl/fir_filter_retimed.sv) | [link]({ROOT_MAT}/designs/16_fir_filter.f) | [link]({ROOT_MAT}/rtl/fir_filter.sv) | [link]({ROOT_MAT}/tb/tb_fir_filter.sv) | [link](fir-filter) |
| 17 | UART RX + TX + FIR Filter [Python code for filtering]({ROOT_MAT}/py/sys_fir_filter_gen.py) | [link]({ROOT_MAT}/designs/17_sys_fir_filter.f) | [link]({ROOT_MAT}/rtl/sys_fir_filter.v) | [link]({ROOT_MAT}/tb/tb_sys_fir_filter.sv) | [link](sys-fir-filter) |

## Waveforms and ASAP7 GDS

For each design our GitHub Actions flow runs

1. Simulation using Verilator, generating VCD, converted to SVG,
2. OpenROAD RTL2GDS2 flow using [ASAP7 7nm, a realistic PDK for academic use,](https://www.sciencedirect.com/science/article/pii/S002626921630026X)

collects their outputs and displays them here. 

To reproduce this on your machine, check out our [docker setup](setting-up-docker.md).

* Our repository: [github.com/abarajithan11/digital-design]({REPO_URL})
* Filelists: [material/designs](https://github.com/abarajithan11/digital-design/tree/main/material/designs)
* SystemVerilog RTL: [material/rtl](https://github.com/abarajithan11/digital-design/tree/main/material/rtl)
* Testbenches: [material/tb](https://github.com/abarajithan11/digital-design/tree/main/material/tb)
* Makefile: [material/Makefile](https://github.com/abarajithan11/digital-design/tree/main/material/Makefile)
* OpenRoad Flow: [material/openroad](https://github.com/abarajithan11/digital-design/tree/main/material/openroad)

""".splitlines()

    for d in designs_data:
        design_numbered = d["design_numbered"]
        heading = d["heading"]
        sim_result = d["sim_result"]
        rtl2gds_result = d["rtl2gds_result"]
        dst = assets_root / design_numbered
        repo_root = REPO_URL + "/blob/main/"
        short_svg = dst / f"{design_numbered}_short.svg"
        flist_rel = d["flist_rel"]
        top_rtl_rel = d["top_rtl_rel"]
        top_tb_rel = d["top_tb_rel"]
        artifact_links = [
            f'<a href="_static/design-outputs/{design_numbered}/{filename}">{label}</a>'
            for label, filename in d["downloadable_assets"]
        ]
        artifact_line = ", ".join(artifact_links) if artifact_links else "Preview assets only"

        lines.extend([f'''## {heading}

**Run results**

- Simulation: {sim_result}, RTL2GDS: {rtl2gds_result}
- Artifacts : {artifact_line}

**Layout Reports**
'''])

        routing_path = f"_static/design-outputs/{design_numbered}/final_routing.webp"
        placement_path = f"_static/design-outputs/{design_numbered}/final_placement.webp"
        worst_path = f"_static/design-outputs/{design_numbered}/final_worst_path.webp"

        if all((dst / img).exists() for img in LAYOUT_IMAGES):
            lines.extend([
                '<div style="display:grid; grid-template-columns:repeat(auto-fit,minmax(220px,1fr)); gap:12px; max-width:1100px; margin:0 auto;">',
                f'  <img src="{routing_path}" alt="{design_numbered} routing" style="width:100%; height:auto; display:block;" />',
                f'  <img src="{placement_path}" alt="{design_numbered} placement" style="width:100%; height:auto; display:block;" />',
                f'  <img src="{worst_path}" alt="{design_numbered} worst path" style="width:100%; height:auto; display:block;" />',
                "</div>",
                '<p style="text-align:center;">Routing, Placement, Worst path</p>',
                "",
            ])
        else:
            lines.append("One or more layout images were not generated.")
            lines.append("")

        lines.extend(["**Waveform (0-16 ns)**", ""])
        if short_svg.exists():
            waveform_path = f"_static/design-outputs/{design_numbered}/{design_numbered}_short.svg"
            lines.extend([
                f'<div class="waveform-svg" data-svg-src="{waveform_path}" role="img" aria-label="{design_numbered} waveform">',
                f'  <a href="{waveform_path}">{design_numbered} waveform</a>',
                "</div>",
            ])
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

    # Rebuild assets output deterministically from downloaded artifacts.
    if assets_root.exists():
        shutil.rmtree(assets_root)
    assets_root.mkdir(parents=True, exist_ok=True)

    # Read sim statuses from downloaded artifact
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

    # Discover designs from source tree
    design_entries = [
        parse_design_entry(p.stem, repo)
        for p in sorted(
            (repo / "material" / "designs").glob("*.f"),
            key=lambda p: int(p.stem.split("_", 1)[0])
        )
    ]
    designs = [entry["design_numbered"] for entry in design_entries]

    if not designs:
        docs_md.write_text(
            "# Design Examples\n\nNo designs found under material/designs.\n",
            encoding="utf-8",
        )
        return

    designs_data = []
    for entry in design_entries:
        design_numbered = entry["design_numbered"]
        dst = assets_root / design_numbered
        dst.mkdir(parents=True, exist_ok=True)
        deployed_dir = deployed_assets_root / design_numbered
        downloadable_assets: list[tuple[str, str]] = []

        # Copy waveform SVGs produced by a local sim_outputs_all run or by CI artifacts.
        sim_svg_short = first_existing_path(
            *[
                root / design_numbered / f"{design_numbered}_short.svg"
                for root in sim_out_assets_roots
            ],
            sim_assets_root / design_numbered / f"{design_numbered}_short.svg",
            deployed_dir / f"{design_numbered}_short.svg",
        )
        if sim_svg_short is not None:
            shutil.copy2(sim_svg_short, dst / f"{design_numbered}_short.svg")

        for label, filename_tmpl in DOWNLOADABLE_ASSETS:
            filename = filename_tmpl.format(design_numbered=design_numbered)
            source_path = downloadable_asset_source(repo, design_numbered, filename, deployed_dir)
            if source_path is not None:
                downloadable_assets.append((label, filename))

        local_reports_dir = local_gds_assets_root / design_numbered / "base"

        for image in LAYOUT_IMAGES:
            source_image = local_reports_dir / image
            if not source_image.exists():
                source_image = gds_assets_root / design_numbered / image
            if not source_image.exists():
                matches = list(gds_assets_root.glob(f"**/{design_numbered}/{image}"))
                if matches:
                    source_image = matches[0]
            if not source_image.exists():
                source_image = deployed_dir / image
            if source_image.exists():
                shutil.copy2(source_image, dst / image)

        raw_status = sim_statuses.get(design_numbered)
        per_design_sim_status = first_existing_text_file(
            repo / "out" / "sim" / f"{design_numbered}.status",
            repo / "sim" / f"{design_numbered}.status",
        )
        if raw_status is None and per_design_sim_status is not None:
            raw_status = per_design_sim_status.read_text(encoding="utf-8").strip()
        if raw_status is None:
            if sim_svg_short is not None:
                raw_status = "pass"
            else:
                raw_status = "unknown"
        gds_status_file = gds_assets_root / design_numbered / "status.txt"
        if gds_status_file.exists():
            rtl2gds_result = "passed" if gds_status_file.read_text(encoding="utf-8").strip() == "pass" else "failed"
        else:
            rtl2gds_result = "passed" if (dst / "final_routing.webp").exists() else "failed"
        designs_data.append({
            **entry,
            "downloadable_assets": downloadable_assets,
            "sim_result": "passed" if raw_status == "pass" else raw_status,
            "rtl2gds_result": rtl2gds_result,
        })

    lines = build_markdown(designs_data, assets_root)
    docs_md.write_text("\n".join(lines) + "\n", encoding="utf-8")
    sync_static_assets(repo)


def main() -> None:
    repo = Path(__file__).resolve().parents[1]
    generate_outputs(repo)


if __name__ == "__main__":
    main()
