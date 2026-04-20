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
    display_name = design_base.replace("_", " ").upper()
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
    lines = f"""# Design Outputs

For each SystemVerilog design available in the course repository, our GitHub Actions flow runs

1. Simulation using Verilator, generating VCD, converted to SVG.
2. OpenROAD RTL2GDS2 flow using [ASAP7 7nm, a realistic PDK for academic use.](https://www.sciencedirect.com/science/article/pii/S002626921630026X)

collects their outputs and displays them here. To reproduce this on your machine, check out our [docker setup](setting-up-docker.md).

## Components of the flow:

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

### Source files

- File List : [{flist_rel}]({repo_root}{flist_rel})
- Top RTL Design : [{top_rtl_rel}]({repo_root}{top_rtl_rel})
- Top Testbench : [{top_tb_rel}]({repo_root}{top_tb_rel})

### Run results

- Simulation: {sim_result}, RTL2GDS: {rtl2gds_result}
- Artefacts : [VCD]({full_vcd_link}), [Full SVG]({full_svg_link}), [GDS]({full_gds_link}), [GDS Logs]({gds_logs_link})

### Waveform (0-10 ns)
'''])
        if short_svg.exists():
            if full_svg.exists():
                lines.append(f"[View full waveform](_static/design-outputs/{design_numbered}/{design_numbered}_full.svg)")
                lines.append("")
            lines.append(f"![{design_numbered} waveform](_static/design-outputs/{design_numbered}/{design_numbered}_short.svg)")
        else:
            lines.append("Waveform SVG not generated.")
        lines.append("")

        lines.extend(["### Layout Reports", ""])

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
    design_entries = [parse_design_entry(p.stem, repo) for p in sorted((repo / "material" / "designs").glob("*.f"))]
    designs = [entry["design_numbered"] for entry in design_entries]

    if not designs:
        docs_md.write_text(
            "# Design Outputs\n\nNo designs found under material/designs.\n",
            encoding="utf-8",
        )
        return

    designs_data = []
    for entry in design_entries:
        design_numbered = entry["design_numbered"]
        dst = assets_root / design_numbered
        dst.mkdir(parents=True, exist_ok=True)

        # Copy waveform SVGs produced by a local sim_outputs_all run or by CI artifacts.
        sim_svg_short = sim_assets_root / design_numbered / f"{design_numbered}_short.svg"
        if sim_svg_short.exists():
            shutil.copy2(sim_svg_short, dst / f"{design_numbered}_short.svg")

        sim_svg_full = sim_assets_root / design_numbered / f"{design_numbered}_full.svg"
        if sim_svg_full.exists():
            shutil.copy2(sim_svg_full, dst / f"{design_numbered}_full.svg")

        sim_vcd = sim_assets_root / design_numbered / f"{design_numbered}.vcd"
        if sim_vcd.exists():
            shutil.copy2(sim_vcd, dst / f"{design_numbered}.vcd")

        local_reports_dir = local_gds_assets_root / design_numbered / "base"
        gds_file = gds_assets_root / design_numbered / f"{design_numbered}.gds"
        if not gds_file.exists():
            local_gds_file = repo / "material" / "openroad" / "work" / "results" / "asap7" / design_numbered / "base" / "6_final.gds"
            if local_gds_file.exists():
                gds_file = local_gds_file
        if gds_file.exists():
            shutil.copy2(gds_file, dst / f"{design_numbered}.gds")

        gds_logs_file = gds_assets_root / design_numbered / "logs.zip"
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
