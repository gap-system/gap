#!/usr/bin/env bash
#
# Assemble a self-contained website from a completed wasm build.
# Outputs ./web-example/ relative to the GAP source root.
#
# Run after etc/emscripten/build.sh (or have build-in-docker.sh call it).

set -euo pipefail

SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
ROOT_DIR=$(cd "$SCRIPT_DIR/../.." && pwd)
OUT_DIR="$ROOT_DIR/web-example"

cd "$ROOT_DIR"

for f in gap.js gap.wasm gap.worker.js gap-fs.json; do
    if [[ ! -f $f ]]; then
        echo "Error: missing build output '$f'. Run etc/emscripten/build.sh first." >&2
        exit 1
    fi
done

# Always start from a clean output directory. Merging into a previous
# web-example/ confuses cp when a tree has changed shape between runs
# (e.g. pkg/X switching between a symlink and a real directory).
rm -rf "$OUT_DIR"
mkdir -p "$OUT_DIR"

cp "$SCRIPT_DIR"/web-template/* "$OUT_DIR"/
cp "$SCRIPT_DIR"/startup_manifest.json "$OUT_DIR"/
cp gap.js gap.wasm gap.worker.js gap-fs.json "$OUT_DIR"/
cp LICENSE COPYRIGHT "$OUT_DIR"/

# Data directories. These are referenced by gap-fs.json and either eagerly
# loaded (if listed in startup_manifest.json) or lazily fetched on first
# read by Emscripten's createLazyFile.
#
# -L follows symlinks so that user setups where pkg/X is a symlink into
# a separate git/X checkout produce a self-contained output tree (the
# user often wants to copy web-example/ to another machine or static
# host where those symlinks would dangle).
for d in pkg lib grp tst doc hpcgap dev benchmark; do
    cp -RL "$d" "$OUT_DIR"/
done

echo "Assembled website at $OUT_DIR"
