#!/usr/bin/env bash
# Runs a command in the Steam Deck build image (platform/steamdeck/app/docker),
# with this repository at /repo.
#
#   tools/deck-build.sh                  a shell
#   tools/deck-build.sh <command...>     e.g. tools/deck-build.sh make steamdeck-app
#
# For an arm64 build (requires qemu-user-static binfmt on the host):
#   DECK_PLATFORM=linux/arm64 \
#   DECK_IMAGE=romm-sync-deck-arm64:6 \
#     docker build --platform linux/arm64 \
#       --build-arg APPIMAGETOOL_URL=.../appimagetool-aarch64.AppImage \
#       --build-arg RUNTIME_URL=.../runtime-aarch64 \
#       -t romm-sync-deck-arm64:6 platform/steamdeck/app/docker
#   DECK_PLATFORM=linux/arm64 DECK_IMAGE=romm-sync-deck-arm64:6 tools/deck-build.sh make steamdeck
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
IMAGE="${DECK_IMAGE:-romm-sync-deck:6}"
PLATFORM="${DECK_PLATFORM:-linux/amd64}"
docker image inspect "$IMAGE" >/dev/null 2>&1 || docker build --platform "$PLATFORM" -t "$IMAGE" "$ROOT/platform/steamdeck/app/docker"
TTY=()
[[ -t 0 && -t 1 ]] && TTY=(-it)
[[ $# -gt 0 ]] || set -- bash
exec docker run --rm --platform "$PLATFORM" ${TTY[@]+"${TTY[@]}"} -u "$(id -u):$(id -g)" -e HOME=/tmp \
    -e BUILD_ID="$(git -C "$ROOT" describe --always --dirty 2>/dev/null)" -e ROMMPS_PAYLOAD_VERSION -e ARCH \
    -v "$ROOT:/repo" -w /repo "$IMAGE" "$@"
