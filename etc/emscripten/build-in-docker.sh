#!/usr/bin/env bash
#
# One-stop shop: build GAP for the web inside a pinned container.
#
# Usage (run from the GAP source tree):
#     etc/emscripten/build-in-docker.sh
#
# Output: ./web-example/ with a self-contained website. Copy it anywhere
# and serve with COOP/COEP headers (etc/emscripten/serve.py is one option).

set -euo pipefail

SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
ROOT_DIR=$(cd "$SCRIPT_DIR/../.." && pwd)

RUNTIME="${CONTAINER_RUNTIME:-}"
if [[ -z "$RUNTIME" ]]; then
    if command -v podman >/dev/null 2>&1; then
        RUNTIME=podman
    elif command -v docker >/dev/null 2>&1; then
        RUNTIME=docker
    else
        echo "Error: neither podman nor docker found in PATH." >&2
        echo "Install one, or set CONTAINER_RUNTIME explicitly." >&2
        exit 1
    fi
fi

IMAGE_TAG="gap-emscripten-build:3.1.23"

# Pin the platform. emscripten/emsdk:3.1.23 is amd64-only on Docker Hub, so on
# Apple Silicon (or any non-amd64 host) the runtime would otherwise renegotiate
# the platform on every build -- that mismatch invalidates the FROM layer's
# cache and cascades through the whole image, defeating the layer cache even
# with --layers. Override with BUILD_PLATFORM if needed.
PLATFORM="${BUILD_PLATFORM:-linux/amd64}"

echo ">> Using container runtime: $RUNTIME (platform: $PLATFORM)"
echo ">> Building image $IMAGE_TAG (cached after first run)"

# --layers is the podman/buildah flag for "use the layer cache"; older
# podman versions default it to false. Docker has caching on by default
# and rejects the flag, so only pass it for podman.
declare -a BUILD_ARGS=(--platform "$PLATFORM")
if [[ "$RUNTIME" != "docker" ]]; then
    BUILD_ARGS+=(--layers)
fi
"$RUNTIME" build "${BUILD_ARGS[@]}" -t "$IMAGE_TAG" -f "$SCRIPT_DIR/Dockerfile" "$SCRIPT_DIR"

# Run as the host user where possible so build outputs are not root-owned.
declare -a USER_ARGS=()
if [[ "$RUNTIME" == "docker" ]]; then
    USER_ARGS=(--user "$(id -u):$(id -g)" -e HOME=/tmp)
else
    # Rootless podman maps host UID to container root by default.
    USER_ARGS=(--userns=keep-id)
fi

echo ">> Building GAP inside container"
"$RUNTIME" run --platform "$PLATFORM" --rm \
    -v "$ROOT_DIR:/gap" \
    -w /gap \
    "${USER_ARGS[@]}" \
    "$IMAGE_TAG" \
    bash etc/emscripten/build.sh

echo ">> Assembling website"
bash "$SCRIPT_DIR/assemble-website.sh"

cat <<EOF

Build complete.
  Website:  $ROOT_DIR/web-example/
  Serve:    cd web-example && ../etc/emscripten/serve.py
  Browse:   http://localhost:8080/

You can copy web-example/ to any static host that returns the headers
  Cross-Origin-Opener-Policy: same-origin
  Cross-Origin-Embedder-Policy: require-corp
EOF
