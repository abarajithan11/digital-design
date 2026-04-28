#!/usr/bin/env python3
"""Render PNG fallback images for GLB files using headless Chrome + model-viewer."""

from __future__ import annotations

import argparse
import http.server
import shutil
import socketserver
import subprocess
import threading
import time
from pathlib import Path
from urllib.parse import quote

MODEL_VIEWER_CDN = "https://cdn.jsdelivr.net/npm/@google/model-viewer@4.2.0/dist/model-viewer.min.js"


class QuietHandler(http.server.SimpleHTTPRequestHandler):
    def log_message(self, format: str, *args: object) -> None:
        return


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


def parse_size(value: str) -> tuple[int, int]:
    parts = value.split(",")
    if len(parts) != 2:
        raise ValueError(f"Invalid --size '{value}', expected WIDTH,HEIGHT")
    width = int(parts[0])
    height = int(parts[1])
    if width <= 0 or height <= 0:
        raise ValueError("--size width and height must be > 0")
    return width, height


def build_page(width: int, height: int) -> str:
    return f"""<!doctype html>
<html>
  <head>
    <meta charset=\"utf-8\"> 
    <script type=\"module\" src=\"{MODEL_VIEWER_CDN}\"></script>
    <style>
      html, body {{
        margin: 0;
        width: 100%;
        height: 100%;
        background: transparent;
        overflow: hidden;
      }}
      model-viewer {{
        width: {width}px;
        height: {height}px;
        display: block;
        background: transparent;
      }}
    </style>
  </head>
  <body>
    <model-viewer
      id=\"mv\"
      alt=\"Standard-cell 3D model fallback\"
      orientation=\"135deg 0deg 0deg\"
      camera-target=\"0m 0m 0m\"
      camera-orbit=\"0deg 150deg 2m\"
      field-of-view=\"30deg\"
      shadow-intensity=\"1\"
      exposure=\"0.85\"
      tone-mapping=\"commerce\"
      environment-image=\"neutral\"
      transparent-background
      ar-status=\"not-presenting\"
      loading=\"eager\">
    </model-viewer>
    <script>
      const params = new URLSearchParams(window.location.search);
      const src = params.get('src');
      if (src) {{
        document.getElementById('mv').setAttribute('src', src);
      }}
    </script>
  </body>
</html>
"""


def serve_repo(repo_root: Path) -> tuple[socketserver.TCPServer, int]:
    handler = lambda *args, **kwargs: QuietHandler(*args, directory=str(repo_root), **kwargs)
    server = socketserver.TCPServer(("127.0.0.1", 0), handler)
    thread = threading.Thread(target=server.serve_forever, daemon=True)
    thread.start()
    return server, int(server.server_address[1])


def render_png(chrome: str, page_url: str, output_path: Path, width: int, height: int) -> None:
    output_path.parent.mkdir(parents=True, exist_ok=True)
    subprocess.run(
        [
            chrome,
            "--headless",
            "--disable-gpu",
            "--hide-scrollbars",
            f"--window-size={width},{height}",
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
    if not output_path.is_file() or output_path.stat().st_size == 0:
        raise RuntimeError(f"Renderer produced empty PNG: {output_path}")


def discover_glbs(root: Path) -> list[Path]:
    return sorted(p for p in root.rglob("*.glb") if p.is_file())


def main() -> int:
    parser = argparse.ArgumentParser(description="Render GLB fallback PNG files")
    parser.add_argument("--repo-root", type=Path, default=Path(__file__).resolve().parents[1])
    parser.add_argument("--root", type=Path, required=True, help="Directory to scan for .glb files")
    parser.add_argument("--size", default="800,880", help="PNG size as WIDTH,HEIGHT")
    parser.add_argument("--overwrite", action="store_true", help="Rewrite existing non-empty PNGs")
    args = parser.parse_args()

    repo_root = args.repo_root.resolve()
    root = args.root.resolve()
    width, height = parse_size(args.size)

    if not root.is_dir():
        raise FileNotFoundError(f"Directory not found: {root}")

    glbs = discover_glbs(root)
    if not glbs:
        print(f"No GLB files found under {root}")
        return 0

    chrome = find_chrome()
    pages_dir = repo_root / "out" / "fallback-pages-auto"
    pages_dir.mkdir(parents=True, exist_ok=True)
    page_path = pages_dir / "render_glb.html"
    page_path.write_text(build_page(width, height), encoding="utf-8")

    server, port = serve_repo(repo_root)
    failures = 0
    rendered = 0
    skipped = 0
    try:
        time.sleep(1.0)
        base_page = f"http://127.0.0.1:{port}/out/fallback-pages-auto/render_glb.html"

        for glb in glbs:
            png = glb.with_suffix(".png")
            if png.is_file() and png.stat().st_size > 0 and not args.overwrite:
                skipped += 1
                continue

            rel_glb = glb.relative_to(repo_root).as_posix()
            page_url = f"{base_page}?src=/{quote(rel_glb)}"
            try:
                render_png(chrome, page_url, png, width, height)
                rendered += 1
                print(f"Wrote {png}")
            except Exception as exc:  # pylint: disable=broad-except
                failures += 1
                print(f"Failed {glb}: {exc}")
    finally:
        server.shutdown()
        server.server_close()

    print(f"Render summary: rendered={rendered} skipped={skipped} failed={failures}")
    return 1 if failures else 0


if __name__ == "__main__":
    raise SystemExit(main())
