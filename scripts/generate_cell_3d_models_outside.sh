#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo_root="${REPO_ROOT:-$(cd "$script_dir/.." && pwd)}"
size="${PNG_SIZE:-800,880}"
overwrite=0
pdks=()

for arg in "$@"; do
  case "$arg" in
    --overwrite)
      overwrite=1
      ;;
    --size=*)
      size="${arg#--size=}"
      ;;
    --help|-h)
      cat <<'EOF'
Usage: generate_cell_3d_models_outside.sh [--overwrite] [--size=WIDTH,HEIGHT] [pdk...]

Renders PNG fallback images from existing GLBs in ./3d.
PDKs default to: all directories under ./3d
EOF
      exit 0
      ;;
    --*)
      printf 'Unknown option: %s\n' "$arg" >&2
      exit 2
      ;;
    *)
      pdks+=("$arg")
      ;;
  esac
done

if [ "${#pdks[@]}" -eq 0 ]; then
  while IFS= read -r dir; do
    pdks+=("$(basename "$dir")")
  done < <(find "$repo_root/3d" -mindepth 1 -maxdepth 1 -type d | sort)
fi

for pdk in "${pdks[@]}"; do
  root="$repo_root/3d/$pdk"
  if [ ! -d "$root" ]; then
    printf 'Skipping missing directory: %s\n' "$root" >&2
    continue
  fi

  cmd=(python3 "$repo_root/scripts/render_glb_fallbacks.py" --repo-root "$repo_root" --root "$root" --size "$size")
  if [ "$overwrite" = "1" ]; then
    cmd+=(--overwrite)
  fi

  printf 'Rendering PNG fallbacks for %s\n' "$pdk"
  "${cmd[@]}"
done
