#!/usr/bin/env python3
"""Download reusable generated assets from the currently deployed site."""
from __future__ import annotations

import argparse
from pathlib import Path
from urllib.error import HTTPError, URLError
from urllib.parse import quote
from urllib.request import Request, urlopen

from generate_outputs import DESIGNS, DOWNLOADABLE_ASSETS, LAYOUT_IMAGES, STATIC_GLB_ASSETS


def fetch(url: str, destination: Path, timeout: int) -> bool:
    """Fetch url to destination, returning False for normal missing-file cases."""
    request = Request(url, headers={"User-Agent": "digital-design-ci-asset-snapshot"})
    try:
        with urlopen(request, timeout=timeout) as response:
            if response.status != 200:
                print(f"skip {url} ({response.status})")
                return False
            data = response.read()
    except HTTPError as exc:
        if exc.code == 404:
            print(f"skip {url} (404)")
            return False
        print(f"skip {url} ({exc.code})")
        return False
    except URLError as exc:
        print(f"skip {url} ({exc.reason})")
        return False
    except TimeoutError as exc:
        print(f"skip {url} ({exc})")
        return False
    except OSError as exc:
        print(f"skip {url} ({exc})")
        return False

    destination.parent.mkdir(parents=True, exist_ok=True)
    destination.write_bytes(data)
    print(f"downloaded {url} -> {destination}")
    return True


def url_join(*parts: str) -> str:
    """Join URL path parts without treating path components as absolute URLs."""
    head, *tail = parts
    url = head.rstrip("/")
    for part in tail:
        url += "/" + quote(part.strip("/"))
    return url


def snapshot_assets(site_url: str, output_root: Path, timeout: int) -> int:
    """Download all known generated assets from the live static site."""
    downloaded = 0
    site_url = site_url.rstrip("/")

    for design in DESIGNS:
        design_name = design["design_name"]
        filenames = [
            tmpl.format(design_name=design_name)
            for _, tmpl in DOWNLOADABLE_ASSETS
        ]
        filenames.extend(LAYOUT_IMAGES)

        for filename in filenames:
            url = url_join(site_url, "_static", "design-outputs", design_name, filename)
            destination = output_root / "_static" / "design-outputs" / design_name / filename
            downloaded += int(fetch(url, destination, timeout))

    for _, filename in STATIC_GLB_ASSETS:
        url = url_join(site_url, "_static", filename)
        destination = output_root / "_static" / filename
        downloaded += int(fetch(url, destination, timeout))

    return downloaded


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--site-url",
        default="https://abapages.com/digital-design",
        help="Base URL of the currently deployed site.",
    )
    parser.add_argument(
        "--out",
        type=Path,
        default=Path("site"),
        help="Directory shaped like the Sphinx output site.",
    )
    parser.add_argument("--timeout", type=int, default=30)
    args = parser.parse_args()

    count = snapshot_assets(args.site_url, args.out, args.timeout)
    print(f"Downloaded {count} live assets")


if __name__ == "__main__":
    main()
