#!/usr/bin/env bash
set -u -o pipefail

repo_root="${REPO_ROOT:-/repo}"
out_root="${OUT_ROOT:-$repo_root/3d}"
layerstack_root="${LAYERSTACK_ROOT:-$repo_root/material/openroad/gds3xtrude}"
render_png="${RENDER_PNG:-1}"
png_size="${PNG_SIZE:-800,880}"
overwrite="${OVERWRITE:-0}"
xy_scale_factor="${GDS3XTRUDE_XY_SCALE:-1.0}"
z_scale_factor="${GDS3XTRUDE_Z_SCALE:-${GDS3XTRUDE_SCALE:-1.0}}"
pdks=()

for arg in "$@"; do
  case "$arg" in
    --overwrite)
      overwrite=1
      ;;
    --help|-h)
      cat <<'EOF'
Usage: generate_cell_3d_models.sh [--overwrite] [pdk...]

PDKs default to: asap7 nangate45 sky130

Environment variables:
  REPO_ROOT        Repository root path (default: /repo)
  OUT_ROOT         Output root path (default: $REPO_ROOT/3d)
  RENDER_PNG       1 to render PNG fallbacks, 0 to skip (default: 1)
  PNG_SIZE         PNG size WIDTH,HEIGHT (default: 800,880)
  OVERWRITE        1 to regenerate scad/glb/png (default: 0)
  GDS3XTRUDE_SCALE Vertical-only scale factor (default: 1.0)
  GDS3XTRUDE_XY_SCALE
                   Uniform x/y scale passed to gds3xtrude (default: 1.0)
  GDS3XTRUDE_Z_SCALE
                   Vertical-only scale factor (default: GDS3XTRUDE_SCALE)
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
  pdks=(asap7 nangate45 sky130)
fi

cell_list() {
  local pdk="$1"
  local gds="$2"

  case "$pdk" in
    asap7)
      strings "$gds" | grep '_ASAP7_75t_R$' | sort -u
      ;;
    nangate45)
      strings "$gds" | grep -E '^[A-Za-z0-9_]+_X[0-9]+$' | sort -u
      ;;
    sky130|sky130hd)
      strings "$gds" | grep '^sky130_fd_sc_hd__' | sort -u
      ;;
    *)
      return 1
      ;;
  esac
}

gds_path() {
  case "$1" in
    asap7)
      printf '%s\n' "$repo_root/material/openroad/OpenROAD-flow-scripts/flow/platforms/asap7/gds/asap7sc7p5t_28_R_220121a.gds"
      ;;
    nangate45)
      printf '%s\n' "$repo_root/material/openroad/OpenROAD-flow-scripts/flow/platforms/nangate45/gds/NangateOpenCellLibrary.gds"
      ;;
    sky130|sky130hd)
      printf '%s\n' "$repo_root/material/openroad/OpenROAD-flow-scripts/flow/platforms/sky130hd/gds/sky130_fd_sc_hd.gds"
      ;;
    *)
      return 1
      ;;
  esac
}

layerstack_path() {
  case "$1" in
    sky130)
      printf '%s\n' "$layerstack_root/sky130hd.layerstack"
      ;;
    *)
      printf '%s\n' "$layerstack_root/$1.layerstack"
      ;;
  esac
}

apply_z_scale() {
  local scad="$1"
  local z_scale="$2"
  local tmp

  if [ "$z_scale" = "1" ] || [ "$z_scale" = "1.0" ] || [ "$z_scale" = "1.00" ]; then
    return 0
  fi

  tmp="${scad}.zscale.$$"
  {
    printf 'scale(v = [1, 1, %.10f]) {\n' "$z_scale"
    sed 's/^/\t/' "$scad"
    printf '}\n'
  } > "$tmp"
  mv "$tmp" "$scad"
}

total_done=0
total_skipped=0
total_failed=0

if [ "$render_png" = "1" ] && ! command -v google-chrome-stable >/dev/null 2>&1 \
  && ! command -v google-chrome >/dev/null 2>&1 \
  && ! command -v chromium-browser >/dev/null 2>&1 \
  && ! command -v chromium >/dev/null 2>&1; then
  printf 'RENDER_PNG=1 requires Chrome/Chromium in PATH\n' >&2
  exit 1
fi

for pdk in "${pdks[@]}"; do
  gds="$(gds_path "$pdk")" || {
    printf 'Skipping unknown PDK: %s\n' "$pdk" >&2
    total_failed=$((total_failed + 1))
    continue
  }
  tech="$(layerstack_path "$pdk")"
  out_dir="$out_root/$pdk"
  pdk_z_scale="$z_scale_factor"

  if [ ! -f "$gds" ]; then
    printf 'Skipping %s: missing GDS %s\n' "$pdk" "$gds" >&2
    total_failed=$((total_failed + 1))
    continue
  fi

  if [ ! -f "$tech" ]; then
    printf 'Skipping %s: missing layerstack %s\n' "$pdk" "$tech" >&2
    total_failed=$((total_failed + 1))
    continue
  fi

  mkdir -p "$out_dir"
  scale_stamp="$out_dir/.gds3xtrude_scale"
  pdk_overwrite="$overwrite"
  prev_scale=""
  if [ -f "$scale_stamp" ]; then
    prev_scale="$(cat "$scale_stamp")"
  fi
  scale_key="xy=$xy_scale_factor z=$pdk_z_scale"
  if [ "$pdk_overwrite" != "1" ] && [ "$prev_scale" != "$scale_key" ]; then
    pdk_overwrite=1
    printf 'scale changed for %s: %s -> %s, forcing regeneration\n' "$pdk" "${prev_scale:-<unset>}" "$scale_key"
  fi

  mapfile -t cells < <(cell_list "$pdk" "$gds")
  printf 'Generating %s cells into %s (%d candidates, xy scale: %s, z scale: %s)\n' "$pdk" "$out_dir" "${#cells[@]}" "$xy_scale_factor" "$pdk_z_scale"

  pdk_done=0
  pdk_skipped=0
  pdk_failed=0

  for cell in "${cells[@]}"; do
    scad="$out_dir/$cell.scad"
    glb="$out_dir/$cell.glb"
    png="$out_dir/$cell.png"

    need_scad=0
    need_glb=0
    need_png=0

    if [ "$pdk_overwrite" = "1" ]; then
      rm -f "$scad" "$glb"
      if [ "$render_png" = "1" ]; then
        rm -f "$png"
      fi
    fi

    if [ ! -s "$glb" ]; then
      need_scad=1
      need_glb=1
    fi

    if [ "$render_png" = "1" ] && [ ! -s "$png" ]; then
      need_scad=1
      need_png=1
    fi

    if [ "$need_glb" = "0" ] && [ "$need_png" = "0" ]; then
      printf 'skip %s %s: artifacts exist (%s%s)\n' "$pdk" "$cell" "$glb" "$( [ "$render_png" = "1" ] && printf ', %s' "$png" )"
      pdk_skipped=$((pdk_skipped + 1))
      continue
    fi

    if [ "$need_scad" = "1" ] && [ ! -s "$scad" ]; then
      printf 'gds3xtrude %s %s (xy scale: %s, z scale: %s)\n' "$pdk" "$cell" "$xy_scale_factor" "$pdk_z_scale"
      if ! gds3xtrude --tech "$tech" --input "$gds" --cell "$cell" --output "$scad" --scale "$xy_scale_factor"; then
        printf 'failed %s %s: gds3xtrude did not produce %s\n' "$pdk" "$cell" "$scad" >&2
        pdk_failed=$((pdk_failed + 1))
        continue
      fi
      apply_z_scale "$scad" "$pdk_z_scale"
    else
      printf 'reuse %s %s: %s exists\n' "$pdk" "$cell" "$scad"
    fi

    if [ "$need_glb" = "1" ]; then
      printf 'convert %s %s\n' "$pdk" "$cell"
      if ! python3 "$repo_root/scripts/scad_to_glb.py" "$scad" "$glb"; then
        printf 'failed %s %s: conversion did not produce %s\n' "$pdk" "$cell" "$glb" >&2
        pdk_failed=$((pdk_failed + 1))
        continue
      fi
    else
      printf 'reuse %s %s: %s exists\n' "$pdk" "$cell" "$glb"
    fi

    pdk_done=$((pdk_done + 1))
  done

  if [ "$render_png" = "1" ]; then
    printf 'render fallbacks %s (%s)\n' "$pdk" "$out_dir"
    if ! python3 "$repo_root/scripts/render_glb_fallbacks.py" --repo-root "$repo_root" --root "$out_dir" --size "$png_size"; then
      printf 'failed %s: fallback PNG rendering failed\n' "$pdk" >&2
      pdk_failed=$((pdk_failed + 1))
    fi
  fi

  if [ "$pdk_failed" -eq 0 ]; then
    printf '%s\n' "$scale_key" > "$scale_stamp"
  fi

  printf 'Done %s: generated=%d skipped=%d failed=%d\n' "$pdk" "$pdk_done" "$pdk_skipped" "$pdk_failed"
  total_done=$((total_done + pdk_done))
  total_skipped=$((total_skipped + pdk_skipped))
  total_failed=$((total_failed + pdk_failed))
done

printf 'All done: generated=%d skipped=%d failed=%d\n' "$total_done" "$total_skipped" "$total_failed"

if [ "$total_failed" -gt 0 ]; then
  exit 1
fi
