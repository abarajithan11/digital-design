#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo_root="${REPO_ROOT:-$(cd "$script_dir/.." && pwd)}"

# Intended for container usage: generate SCAD + GLB only.
RENDER_PNG=0 "$repo_root/scripts/generate_cell_3d_models.sh" "$@"
