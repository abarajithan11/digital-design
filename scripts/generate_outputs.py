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
        design = d["design"]
        sim_result = d["sim_result"]
        rtl2gds_result = d["rtl2gds_result"]
        dst = assets_root / design
        repo_root = REPO_URL + "/blob/main/"
        short_svg = dst / f"{design}_short.svg"
        full_svg = dst / f"{design}_full.svg"
        full_svg_link = f"_static/design-outputs/{design}/{design}_full.svg"

        lines.extend([f'''## {design}

- Simulation result: {sim_result}
- RTL2GDS result: {rtl2gds_result}

### Source files:

- File List : [material/designs/{design}.f]({repo_root}material/designs/{design}.f)
- Top RTL Design : [material/rtl/{design}.sv]({repo_root}material/rtl/{design}.sv)
- Top Testbench : [material/tb/tb_{design}.sv]({repo_root}material/tb/tb_{design}.sv)
- Full waveform SVG : [view]({full_svg_link})

### Simulation Waveform (First 10 ns)
'''])
        if short_svg.exists():
            if full_svg.exists():
                lines.append(f"[View full waveform](_static/design-outputs/{design}/{design}_full.svg)")
                lines.append("")
            lines.append(f"![{design} waveform](_static/design-outputs/{design}/{design}_short.svg)")
        else:
            lines.append("Waveform SVG not generated.")
        lines.append("")

        lines.extend(["### Layout Reports", ""])

        routing_path = f"_static/design-outputs/{design}/final_routing.webp"
        placement_path = f"_static/design-outputs/{design}/final_placement.webp"
        worst_path = f"_static/design-outputs/{design}/final_worst_path.webp"

        if all((dst / img).exists() for img in LAYOUT_IMAGES):
            lines.extend([
                '<div style="display:grid; grid-template-columns:repeat(auto-fit,minmax(220px,1fr)); gap:12px; max-width:1100px; margin:0 auto;">',
                f'  <img src="{routing_path}" alt="{design} routing" style="width:100%; height:auto; display:block;" />',
                f'  <img src="{placement_path}" alt="{design} placement" style="width:100%; height:auto; display:block;" />',
                f'  <img src="{worst_path}" alt="{design} worst path" style="width:100%; height:auto; display:block;" />',
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
    designs = sorted(p.stem for p in (repo / "material" / "designs").glob("*.f"))

    if not designs:
        docs_md.write_text(
            "# Design Outputs\n\nNo designs found under material/designs.\n",
            encoding="utf-8",
        )
        return

    designs_data = []
    for design in designs:
        dst = assets_root / design
        dst.mkdir(parents=True, exist_ok=True)

        # Copy waveform SVGs produced by a local sim_outputs_all run or by CI artifacts.
        sim_svg_short = sim_assets_root / design / f"{design}_short.svg"
        if sim_svg_short.exists():
            shutil.copy2(sim_svg_short, dst / f"{design}_short.svg")

        sim_svg_full = sim_assets_root / design / f"{design}_full.svg"
        if sim_svg_full.exists():
            shutil.copy2(sim_svg_full, dst / f"{design}_full.svg")

        local_reports_dir = local_gds_assets_root / design / "base"
        for image in LAYOUT_IMAGES:
            source_image = local_reports_dir / image
            if not source_image.exists():
                source_image = gds_assets_root / design / image
            if not source_image.exists():
                matches = list(gds_assets_root.glob(f"**/{design}/{image}"))
                if matches:
                    source_image = matches[0]
            if source_image.exists():
                shutil.copy2(source_image, dst / image)

        raw_status = sim_statuses.get(design)
        per_design_sim_status = repo / "out" / "sim" / f"{design}.status"
        if raw_status is None and per_design_sim_status.exists():
            raw_status = per_design_sim_status.read_text(encoding="utf-8").strip()
        if raw_status is None:
            if sim_svg_short.exists() or sim_svg_full.exists() or (sim_assets_root / design / f"{design}.vcd").exists():
                raw_status = "pass"
            else:
                raw_status = "unknown"
        gds_status_file = gds_assets_root / design / "status.txt"
        if gds_status_file.exists():
            rtl2gds_result = "passed" if gds_status_file.read_text(encoding="utf-8").strip() == "pass" else "failed"
        else:
            rtl2gds_result = "passed" if (dst / "final_routing.webp").exists() else "failed"
        designs_data.append({
            "design": design,
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
