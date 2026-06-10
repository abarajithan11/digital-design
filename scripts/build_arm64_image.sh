#!/usr/bin/env bash
# Build the digital-design container natively for linux/arm64 (Apple Silicon
# Macs, arm64 Linux), without relying on Rosetta/QEMU emulation of the
# amd64-only openroad/orfs image.
#
# Two-stage build:
#   1. Dockerfile.arm64-base: compiles OpenROAD-flow-scripts from source for
#      arm64 (slow, ~hours). Reused/cached as $BASE_IMAGE.
#   2. Dockerfile: our usual extra packages on top of that base (fast).
#
# Usage:
#   scripts/build_arm64_image.sh
#
# Env vars:
#   ORFS_REF     OpenROAD-flow-scripts git ref to build (default: 26Q2)
#   BASE_IMAGE   Tag for the from-source ORFS base image
#                (default: ghcr.io/ucsd-cse140-s126/digital-design:orfs-arm64-base-$ORFS_REF)
#   IMAGE        Tag for the final image (default: digital-design:arm64)
#   PUSH         If "1", push BASE_IMAGE to its registry when (re)built (default: 0)
#   NUM_THREADS  Build parallelism (default: nproc)
#   USE_GHA_CACHE If "1", use the GitHub Actions buildx cache backend

set -euo pipefail
cd "$(dirname "$(readlink -f "$0")")/.."

ORFS_REF="${ORFS_REF:-26Q2}"
BASE_IMAGE="${BASE_IMAGE:-ghcr.io/ucsd-cse140-s126/digital-design:orfs-arm64-base-${ORFS_REF}}"
IMAGE="${IMAGE:-digital-design:arm64}"
PUSH="${PUSH:-0}"
NUM_THREADS="${NUM_THREADS:-$(nproc)}"

USR="$(id -un)"
UID_NUM="$(id -u)"
GID_NUM="$(id -g)"
CONT_ROOT="/repo/material"

CACHE_BASE_ARGS=()
CACHE_FINAL_ARGS=()
if [[ "${USE_GHA_CACHE:-0}" == "1" ]]; then
    CACHE_BASE_ARGS=(--cache-from "type=gha,scope=arm64-base-${ORFS_REF}" --cache-to "type=gha,mode=max,scope=arm64-base-${ORFS_REF}")
    CACHE_FINAL_ARGS=(--cache-from "type=gha,scope=arm64-final" --cache-to "type=gha,mode=max,scope=arm64-final")
fi

echo "==> Stage 1/2: OpenROAD-flow-scripts arm64 base (${BASE_IMAGE})"
if docker manifest inspect "${BASE_IMAGE}" >/dev/null 2>&1; then
    echo "Base image already published, skipping from-source build."
elif [[ "${PUSH}" == "1" ]]; then
    docker buildx build \
        --platform linux/arm64 \
        -f Dockerfile.arm64-base \
        --build-arg ORFS_REF="${ORFS_REF}" \
        --build-arg NUM_THREADS="${NUM_THREADS}" \
        "${CACHE_BASE_ARGS[@]}" \
        -t "${BASE_IMAGE}" \
        --push \
        .
else
    if ! docker image inspect "${BASE_IMAGE}" >/dev/null 2>&1; then
        docker buildx build \
            --platform linux/arm64 \
            -f Dockerfile.arm64-base \
            --build-arg ORFS_REF="${ORFS_REF}" \
            --build-arg NUM_THREADS="${NUM_THREADS}" \
            "${CACHE_BASE_ARGS[@]}" \
            -t "${BASE_IMAGE}" \
            --load \
            .
    else
        echo "Base image already built locally, skipping from-source build."
    fi
fi

echo "==> Stage 2/2: digital-design arm64 image (${IMAGE})"
docker buildx build \
    --platform linux/arm64 \
    -f Dockerfile \
    --build-arg ORFS_BASE_IMAGE="${BASE_IMAGE}" \
    --build-arg UID="${UID_NUM}" \
    --build-arg GID="${GID_NUM}" \
    --build-arg USERNAME="${USR}" \
    --build-arg CONT_ROOT="${CONT_ROOT}" \
    "${CACHE_FINAL_ARGS[@]}" \
    -t "${IMAGE}" \
    --load \
    .

echo "==> Built ${IMAGE}"
