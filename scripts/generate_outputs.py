#!/usr/bin/env python3
"""Generate docs/design_outputs.md from existing simulation and GDS artifacts."""
from pathlib import Path
import shutil

LAYOUT_IMAGES = [
    "final_routing.webp",
    "final_placement.webp",
    "final_worst_path.webp",
]

REPO_URL = "https://github.com/abarajithan11/digital-design"


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

def build_markdown(designs_data: list[dict], assets_root: Path) -> list[str]:
    """Return markdown lines for all designs given pre-resolved data."""
    lines = f"""# Design Examples

In this course, digital design concepts and SystemVerilog features will be introduced through examples of gradually increasing complexity, inspired by real digital systems, as follows:

| # | Design | File List | RTL | TB | Sim & GDS |
|---|---|---|---|---|---|
| 1 | Not Gate | [link](https://github.com/abarajithan11/digital-design/blob/main/material/designs/1_not_gate.f) | [link](https://github.com/abarajithan11/digital-design/blob/main/material/rtl/not_gate.sv) | [link](https://github.com/abarajithan11/digital-design/blob/main/material/tb/tb_not_gate.sv) | [link](#1-not-gate) |
| 2 | Full Adder | [link](https://github.com/abarajithan11/digital-design/blob/main/material/designs/2_full_adder.f) | [link](https://github.com/abarajithan11/digital-design/blob/main/material/rtl/full_adder.sv) | [link](https://github.com/abarajithan11/digital-design/blob/main/material/tb/tb_full_adder.sv) | [link](#2-full-adder) |
| 3 | N-Adder | [link](https://github.com/abarajithan11/digital-design/blob/main/material/designs/3_n_adder.f) | [link](https://github.com/abarajithan11/digital-design/blob/main/material/rtl/n_adder.sv) | [link](https://github.com/abarajithan11/digital-design/blob/main/material/tb/tb_n_adder.sv) | [link](#3-n-adder) |
| 4 | ALU | [link](https://github.com/abarajithan11/digital-design/blob/main/material/designs/4_alu.f) | [link](https://github.com/abarajithan11/digital-design/blob/main/material/rtl/alu.sv) | [link](https://github.com/abarajithan11/digital-design/blob/main/material/tb/tb_alu.sv) | [link](#4-alu) |
| 5 | Encoder | — | — | — | — |
| 6 | Decoder | — | — | — | — |
| 7 | Verilog Functions | — | — | — | — |
| 8 | Flip Flop | [link](https://github.com/abarajithan11/digital-design/blob/main/material/designs/8_flip_flop.f) | [link](https://github.com/abarajithan11/digital-design/blob/main/material/rtl/flip_flop.sv) | [link](https://github.com/abarajithan11/digital-design/blob/main/material/tb/tb_flip_flop.sv) | [link](#8-flip-flop) |
| 9 | Up counter | [link](https://github.com/abarajithan11/digital-design/blob/main/material/designs/9_up_counter.f) | [link](https://github.com/abarajithan11/digital-design/blob/main/material/rtl/up_counter.sv) | [link](https://github.com/abarajithan11/digital-design/blob/main/material/tb/tb_up_counter.sv) | [link](#9-up-counter) |
| 10 | Binary Reduction Tree to find minimum of a vector `y = min(X)` | [link](https://github.com/abarajithan11/digital-design/blob/main/material/designs/18_reduction_tree_min.f) | [link](https://github.com/abarajithan11/digital-design/blob/main/material/rtl/reduction_tree_min.sv) | [link](https://github.com/abarajithan11/digital-design/blob/main/material/tb/tb_reduction_tree_min.sv) | [link](#18-reduction-tree-min) |
| 11 | Parallel to Serial Converter | [link](https://github.com/abarajithan11/digital-design/blob/main/material/designs/11_parallel_to_serial.f) | [link](https://github.com/abarajithan11/digital-design/blob/main/material/rtl/parallel_to_serial.sv) | [link](https://github.com/abarajithan11/digital-design/blob/main/material/tb/tb_parallel_to_serial.sv) | [link](#11-parallel-to-serial) |
| 12 | Down counter | [link](https://github.com/abarajithan11/digital-design/blob/main/material/designs/12_down_counter.f) | [link](https://github.com/abarajithan11/digital-design/blob/main/material/rtl/down_counter.sv) | [link](https://github.com/abarajithan11/digital-design/blob/main/material/tb/tb_down_counter.sv) | [link](#12-down-counter) |
| 13 | UART RX | [link](https://github.com/abarajithan11/digital-design/blob/main/material/designs/13_uart_rx.f) | [link](https://github.com/abarajithan11/digital-design/blob/main/material/rtl/uart_rx.sv) | [link](https://github.com/abarajithan11/digital-design/blob/main/material/tb/tb_uart_rx.sv) | [link](#13-uart-rx) |
| 14 | UART TX | [link](https://github.com/abarajithan11/digital-design/blob/main/material/designs/14_uart_tx.f) | [link](https://github.com/abarajithan11/digital-design/blob/main/material/rtl/uart_tx.sv) | [link](https://github.com/abarajithan11/digital-design/blob/main/material/tb/tb_uart_tx.sv) | [link](#14-uart-tx) |
| 15 | UART Echo (RX + TX) | [link](https://github.com/abarajithan11/digital-design/blob/main/material/designs/15_uart_echo.f) | [link](https://github.com/abarajithan11/digital-design/blob/main/material/rtl/uart_echo.v) | [link](https://github.com/abarajithan11/digital-design/blob/main/material/tb/tb_uart_echo.sv) | [link](#15-uart-echo) |
| 16 | FIR Filter [Retimed RTL](https://github.com/abarajithan11/digital-design/blob/main/material/rtl/fir_filter_retimed.sv) | [link](https://github.com/abarajithan11/digital-design/blob/main/material/designs/16_fir_filter.f) | [link](https://github.com/abarajithan11/digital-design/blob/main/material/rtl/fir_filter.sv) | [link](https://github.com/abarajithan11/digital-design/blob/main/material/tb/tb_fir_filter.sv) | [link](#16-fir-filter) |
| 17 | UART RX + TX + FIR Filter | [link](https://github.com/abarajithan11/digital-design/blob/main/material/designs/17_sys_fir_filter.f) | [link](https://github.com/abarajithan11/digital-design/blob/main/material/rtl/sys_fir_filter.sv) | [link](https://github.com/abarajithan11/digital-design/blob/main/material/tb/tb_sys_fir_filter.sv) | [link](#17-sys-fir-filter) |

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
        full_svg = dst / f"{design_numbered}_full.svg"
        full_svg_link = f"_static/design-outputs/{design_numbered}/{design_numbered}_full.svg"
        full_vcd_link = f"_static/design-outputs/{design_numbered}/{design_numbered}.vcd"
        full_gds_link = f"_static/design-outputs/{design_numbered}/{design_numbered}.gds"
        gds_logs_link = f"_static/design-outputs/{design_numbered}/logs.zip"
        flist_rel = d["flist_rel"]
        top_rtl_rel = d["top_rtl_rel"]
        top_tb_rel = d["top_tb_rel"]

        lines.extend([f'''## {heading}

**Run results**

- Simulation: {sim_result}, RTL2GDS: {rtl2gds_result}
- Artifacts : [VCD]({full_vcd_link}), [Full SVG]({full_svg_link}), [GDS]({full_gds_link}), [GDS Logs]({gds_logs_link})

**Waveform (0-10 ns)**
'''])
        if short_svg.exists():
            if full_svg.exists():
                lines.append("")
            lines.append(f"![{design_numbered} waveform](_static/design-outputs/{design_numbered}/{design_numbered}_short.svg)")
        else:
            lines.append("Waveform SVG not generated.")
        lines.append("")

        lines.extend(["**Layout Reports**", ""])

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

    return lines


def generate_outputs(repo: Path) -> None:
    """Assemble markdown from pre-built local or CI-downloaded artifacts."""
    docs_md = repo / "docs" / "design_outputs.md"
    assets_root = repo / "docs" / "_static" / "design-outputs"
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
    status_file = repo / "out" / "sim" / "status.tsv"
    if status_file.exists():
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

        # Copy waveform SVGs produced by a local sim_outputs_all run or by CI artifacts.
        sim_svg_short = sim_assets_root / design_numbered / f"{design_numbered}_short.svg"
        if not sim_svg_short.exists():
            sim_svg_short = deployed_dir / f"{design_numbered}_short.svg"
        if sim_svg_short.exists():
            shutil.copy2(sim_svg_short, dst / f"{design_numbered}_short.svg")

        sim_svg_full = sim_assets_root / design_numbered / f"{design_numbered}_full.svg"
        if not sim_svg_full.exists():
            sim_svg_full = deployed_dir / f"{design_numbered}_full.svg"
        if sim_svg_full.exists():
            shutil.copy2(sim_svg_full, dst / f"{design_numbered}_full.svg")

        sim_vcd = sim_assets_root / design_numbered / f"{design_numbered}.vcd"
        if not sim_vcd.exists():
            sim_vcd = deployed_dir / f"{design_numbered}.vcd"
        if sim_vcd.exists():
            shutil.copy2(sim_vcd, dst / f"{design_numbered}.vcd")

        local_reports_dir = local_gds_assets_root / design_numbered / "base"
        gds_file = gds_assets_root / design_numbered / f"{design_numbered}.gds"
        if not gds_file.exists():
            local_gds_file = repo / "material" / "openroad" / "work" / "results" / "asap7" / design_numbered / "base" / "6_final.gds"
            if local_gds_file.exists():
                gds_file = local_gds_file
            else:
                gds_file = deployed_dir / f"{design_numbered}.gds"
        if gds_file.exists():
            shutil.copy2(gds_file, dst / f"{design_numbered}.gds")

        gds_logs_file = gds_assets_root / design_numbered / "logs.zip"
        if not gds_logs_file.exists():
            gds_logs_file = deployed_dir / "logs.zip"
        if gds_logs_file.exists():
            shutil.copy2(gds_logs_file, dst / "logs.zip")

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
        per_design_sim_status = repo / "out" / "sim" / f"{design_numbered}.status"
        if raw_status is None and per_design_sim_status.exists():
            raw_status = per_design_sim_status.read_text(encoding="utf-8").strip()
        if raw_status is None:
            if sim_svg_short.exists() or sim_svg_full.exists() or sim_vcd.exists():
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
            "sim_result": "passed" if raw_status == "pass" else raw_status,
            "rtl2gds_result": rtl2gds_result,
        })

    lines = build_markdown(designs_data, assets_root)
    docs_md.write_text("\n".join(lines) + "\n", encoding="utf-8")


def main() -> None:

    repo = Path(__file__).resolve().parents[1]
    generate_outputs(repo)


if __name__ == "__main__":
    main()
