#!/usr/bin/env python3
"""Generate docs/design_outputs.md from simulation and GDS artifacts.

Modes:
  default         Run containers for wave_svg + gds, copy assets, write markdown.
                  Used by ci-gds-docs (local/legacy).
  --generate-only Read already-built artifacts from disk, write markdown only.
                  Used by CI build-pages job after downloading sim + gds artifacts.
"""
import argparse
from pathlib import Path
import os
import shutil
import subprocess

LAYOUT_IMAGES = [
    "final_routing.webp",
    "final_placement.webp",
    "final_worst_path.webp",
]

REPO_URL = "https://github.com/abarajithan11/digital-design"


def run_in_container(ci_image: str, cmd: str) -> str:
    command = ["make", "run", f"CI_IMAGE={ci_image}", f"CMD={cmd}"]
    result = subprocess.run(command, check=False)
    return "pass" if result.returncode == 0 else "fail"


def build_markdown(designs_data: list[dict], assets_root: Path) -> list[str]:
    """Return markdown lines for all designs given pre-resolved data."""
    lines = f"""# Design Outputs

For each SystemVerilog design available in the course repository, our GitHub Actions flow runs

1. Simulation using Verilator, generating VCD, converted to SVG
2. OpenROAD RTL2GDS2 flow using ASAP7 (7nm educational PDK)

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

        sim_link = f"{REPO_URL}/blob/main/material/tb/tb_{design}.sv"
        rtl2gds_link = f"{REPO_URL}/tree/main/material/openroad"

        lines.extend([
            f"## {design}",
            "",
            f"- [Simulation]({sim_link}): {sim_result}",
            f"- [RTL2GDS]({rtl2gds_link}): {rtl2gds_result}",
            "",
            "### Simulation Waveform",
            "",
        ])

        if (dst / f"{design}.svg").exists():
            lines.append(f"![{design} waveform](_static/design-outputs/{design}/{design}.svg)")
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


def mode_generate_only(repo: Path) -> None:
    """Assemble markdown from pre-built artifacts — no container calls."""
    docs_md = repo / "docs" / "design_outputs.md"
    assets_root = repo / "docs" / "_static" / "design-outputs"
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

        # Copy SVG produced by sim job
        sim_svg = repo / "material" / "sim" / design / f"{design}.svg"
        if sim_svg.exists():
            shutil.copy2(sim_svg, dst / f"{design}.svg")

        for image in LAYOUT_IMAGES:
            source_image = gds_assets_root / design / image
            if not source_image.exists():
                matches = list(gds_assets_root.glob(f"**/{design}/{image}"))
                if matches:
                    source_image = matches[0]
            if source_image.exists():
                shutil.copy2(source_image, dst / image)

        raw_status = sim_statuses.get(design, "unknown")
        designs_data.append({
            "design": design,
            "sim_result": "passed" if raw_status == "pass" else raw_status,
            "rtl2gds_result": "passed" if (dst / "final_routing.webp").exists() else "failed",
        })

    lines = build_markdown(designs_data, assets_root)
    docs_md.write_text("\n".join(lines) + "\n", encoding="utf-8")


def mode_full(repo: Path) -> None:
    """Run containers, copy all assets, write markdown."""
    ci_image = os.environ.get("CI_IMAGE", "pages-layouts:latest")
    sim_status_file = repo / "out" / "sim" / "status.tsv"
    docs_md = repo / "docs" / "design_outputs.md"
    assets_root = repo / "docs" / "_static" / "design-outputs"

    if assets_root.exists():
        shutil.rmtree(assets_root)
    assets_root.mkdir(parents=True, exist_ok=True)

    if not sim_status_file.exists() or sim_status_file.stat().st_size == 0:
        docs_md.write_text(
            "# Design Outputs\n\nNo designs found under material/designs.\n",
            encoding="utf-8",
        )
        return

    designs_data = []
    for row in sim_status_file.read_text(encoding="utf-8").splitlines():
        if not row.strip():
            continue

        design, sim_status = row.split("\t", maxsplit=1)
        sim_svg_status = run_in_container(ci_image, f"make wave_svg DESIGN={design}")
        gds_status = run_in_container(ci_image, f"make gds DESIGN={design}")

        dst = assets_root / design
        dst.mkdir(parents=True, exist_ok=True)

        sim_svg = repo / "material" / "sim" / design / f"{design}.svg"
        if sim_svg.exists():
            shutil.copy2(sim_svg, dst / f"{design}.svg")

        src_layout = repo / "material" / "openroad" / "work" / "reports" / "asap7" / design / "base"
        for image in LAYOUT_IMAGES:
            source_image = src_layout / image
            if source_image.exists():
                shutil.copy2(source_image, dst / image)

        designs_data.append({
            "design": design,
            "sim_result": "passed" if sim_status.strip().lower() == "pass" else "failed",
            "rtl2gds_result": "passed" if gds_status.strip().lower() == "pass" else "failed",
        })

    lines = build_markdown(designs_data, assets_root)
    docs_md.write_text("\n".join(lines) + "\n", encoding="utf-8")


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--generate-only",
        action="store_true",
        help="Assemble markdown from existing artifacts without running containers.",
    )
    args = parser.parse_args()

    repo = Path(__file__).resolve().parents[1]
    os.chdir(repo)

    if args.generate_only:
        mode_generate_only(repo)
    else:
        mode_full(repo)


if __name__ == "__main__":
    main()