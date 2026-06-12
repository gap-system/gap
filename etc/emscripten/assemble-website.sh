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

for f in gap.js gap.wasm gap-fs.json; do
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

cp -R "$SCRIPT_DIR"/web-template/* "$OUT_DIR"/
cp "$SCRIPT_DIR"/startup_manifest.json "$OUT_DIR"/
cp gap.js gap.wasm gap-fs.json "$OUT_DIR"/
# Emscripten only emits a separate gap.worker.js for pthread builds; this
# single-threaded ASYNCIFY build doesn't use one (newer emscripten inlines
# the worker regardless). Copy it only if it was produced.
if [[ -f gap.worker.js ]]; then
    cp gap.worker.js "$OUT_DIR"/
fi
cp LICENSE COPYRIGHT "$OUT_DIR"/

# Data directories. These are referenced by gap-fs.json and either eagerly
# loaded (if listed in startup_manifest.json) or lazily fetched on first
# read by Emscripten's createLazyFile.
#
# tar -h dereferences symlinks so the output tree is self-contained (a
# setup where pkg/X is a symlink into a separate checkout still works);
# --exclude .git keeps such checkouts' git internals out of the shipped
# site. Some packages ship dangling symlinks as build artefacts (e.g.
# pkg/vole's rust/target/*.dSYM); tar reports those and exits non-zero
# but still copies everything else, so we don't let that abort the run.
# The assertion below catches a genuinely incomplete copy.
for d in pkg lib grp tst doc hpcgap dev benchmark; do
    tar -c -h --exclude '.git' -f - "$d" 2>/dev/null | tar -x -C "$OUT_DIR" -f - || true
done

# pkg/log holds package test logs (.log/.err/.out) that are never read at
# runtime; keep them out of the shipped site.
rm -rf "$OUT_DIR/pkg/log"

# The library bootstrap must be present, or GAP 404s during startup.
if [[ ! -f "$OUT_DIR/lib/init.g" ]]; then
    echo "Error: lib/init.g missing from $OUT_DIR after copy." >&2
    exit 1
fi

echo "Assembled website at $OUT_DIR"
