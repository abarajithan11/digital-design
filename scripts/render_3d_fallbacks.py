#!/usr/bin/env python3
"""Render default-view PNG fallback images for the course 3D models."""

from __future__ import annotations

import http.server
import os
import shutil
import socketserver
import subprocess
import sys
import tempfile
import threading
import time
from pathlib import Path


REPO_ROOT = Path(__file__).resolve().parents[1]
OUT_ROOT = REPO_ROOT / "out"
PAGES_DIR = OUT_ROOT / "fallback-pages"
PNGS_DIR = OUT_ROOT / "fallback-pngs"
DOCS_STATIC_DIR = REPO_ROOT / "docs" / "_static"

MODEL_VIEWER_CDN = "https://cdn.jsdelivr.net/npm/@google/model-viewer@4.2.0/dist/model-viewer.min.js"

MODELS = [
    {
        "page_name": "n_adder.html",
        "png_name": "n_adder.png",
        "glb_path": "out/gds-assets/3_n_adder/n_adder.glb",
        "alt": "8-bit ripple carry adder circuit in 7nm (ASAP7) visualized in 3D",
        "camera_target": "0m 0m 0m",
        "camera_orbit": "0deg 150deg 1m",
        "field_of_view": "50deg",
        "exposure": "0.8",
        "width": "1200",
        "height": "760",
    },
    {
        "page_name": "inv_3d.html",
        "png_name": "inv_3d.png",
        "glb_path": "out/gds-assets/cell_3d/INVx1_ASAP7_75t_R.glb",
        "alt": "NOT gate standard cell in ASAP7 visualized in 3D",
        "camera_target": "0m 0m 0m",
        "camera_orbit": "0deg 150deg 2m",
        "field_of_view": "30deg",
        "exposure": "0.85",
        "width": "800",
        "height": "880",
    },
    {
        "page_name": "nand_3d.html",
        "png_name": "nand_3d.png",
        "glb_path": "out/gds-assets/cell_3d/NAND2x1_ASAP7_75t_R.glb",
        "alt": "NAND gate standard cell in ASAP7 visualized in 3D",
        "camera_target": "0m 0m 0m",
        "camera_orbit": "0deg 150deg 2.5m",
        "field_of_view": "30deg",
        "exposure": "0.85",
        "width": "800",
        "height": "880",
    },
    {
        "page_name": "aoi211_3d.html",
        "png_name": "aoi211_3d.png",
        "glb_path": "out/gds-assets/cell_3d/AOI211x1_ASAP7_75t_R.glb",
        "alt": "And-or-invert standard cell in ASAP7 visualized in 3D",
        "camera_target": "0m 0m 0m",
        "camera_orbit": "0deg 150deg 1.5m",
        "field_of_view": "30deg",
        "exposure": "0.85",
        "width": "800",
        "height": "880",
    },
    {
        "page_name": "dff_3d.html",
        "png_name": "dff_3d.png",
        "glb_path": "out/gds-assets/cell_3d/DFFHQNx1_ASAP7_75t_R.glb",
        "alt": "D flip-flop standard cell in ASAP7 visualized in 3D",
        "camera_target": "0m 0m 0m",
        "camera_orbit": "0deg 150deg 1.5m",
        "field_of_view": "30deg",
        "exposure": "0.85",
        "width": "800",
        "height": "880",
    },
]


def find_chrome() -> str:
    for candidate in (
        "google-chrome-stable",
        "google-chrome",
        "chromium-browser",
        "chromium",
    ):
        path = shutil.which(candidate)
        if path:
            return path
    raise FileNotFoundError(
        "Could not find a Chrome/Chromium executable. "
        "Tried google-chrome-stable, google-chrome, chromium-browser, chromium."
    )


def build_page(model: dict[str, str]) -> str:
    return f"""<!doctype html>
<html>
  <head>
    <meta charset="utf-8">
    <title>{model["png_name"]}</title>
    <script type="module" src="{MODEL_VIEWER_CDN}"></script>
    <style>
      html, body {{
        margin: 0;
        width: 100%;
        height: 100%;
        background: transparent;
        overflow: hidden;
      }}

      body {{
        display: block;
      }}

      model-viewer {{
        width: {model["width"]}px;
        height: {model["height"]}px;
        display: block;
        background: transparent;
      }}
    </style>
  </head>
  <body>
    <model-viewer
      src="/{model["glb_path"]}"
      alt="{model["alt"]}"
      orientation="135deg 0deg 0deg"
      camera-target="{model["camera_target"]}"
      camera-orbit="{model["camera_orbit"]}"
      field-of-view="{model["field_of_view"]}"
      shadow-intensity="1"
      exposure="{model["exposure"]}"
      tone-mapping="commerce"
      environment-image="neutral"
      transparent-background
      ar-status="not-presenting"
      loading="eager">
    </model-viewer>
  </body>
</html>
"""


class QuietHandler(http.server.SimpleHTTPRequestHandler):
    def log_message(self, format: str, *args: object) -> None:
        return


def serve_repo() -> tuple[socketserver.TCPServer, int]:
    handler = lambda *args, **kwargs: QuietHandler(*args, directory=str(REPO_ROOT), **kwargs)
    server = socketserver.TCPServer(("127.0.0.1", 0), handler)
    thread = threading.Thread(target=server.serve_forever, daemon=True)
    thread.start()
    return server, int(server.server_address[1])


def ensure_assets_exist() -> None:
    missing = [m["glb_path"] for m in MODELS if not (REPO_ROOT / m["glb_path"]).is_file()]
    if missing:
        missing_text = "\n".join(f"- {path}" for path in missing)
        raise FileNotFoundError(
            "Missing GLB assets. Run `make gds_glb_assets` first.\n" + missing_text
        )


def render_png(chrome: str, port: int, model: dict[str, str]) -> None:
    output_path = PNGS_DIR / model["png_name"]
    page_url = f"http://127.0.0.1:{port}/out/fallback-pages/{model['page_name']}"
    subprocess.run(
        [
            chrome,
            "--headless",
            "--disable-gpu",
            "--hide-scrollbars",
            f"--window-size={model['width']},{model['height']}",
            "--force-device-scale-factor=1",
            "--default-background-color=00000000",
            "--virtual-time-budget=5000",
            f"--screenshot={output_path}",
            page_url,
        ],
        check=True,
        stdout=subprocess.DEVNULL,
        stderr=subprocess.DEVNULL,
    )


def main() -> int:
    chrome = find_chrome()
    ensure_assets_exist()

    PAGES_DIR.mkdir(parents=True, exist_ok=True)
    PNGS_DIR.mkdir(parents=True, exist_ok=True)
    DOCS_STATIC_DIR.mkdir(parents=True, exist_ok=True)

    for model in MODELS:
        (PAGES_DIR / model["page_name"]).write_text(build_page(model), encoding="utf-8")

    server, port = serve_repo()
    try:
        time.sleep(1.0)
        for model in MODELS:
            render_png(chrome, port, model)
            shutil.copy2(PNGS_DIR / model["png_name"], DOCS_STATIC_DIR / model["png_name"])
            print(f"Wrote {PNGS_DIR / model['png_name']}")
    finally:
        server.shutdown()
        server.server_close()

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
