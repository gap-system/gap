#!/usr/bin/env bash

# Run dev/run-julia-gc-analyzer.sh over every in-scope GAP translation unit and
# summarise the result. Logs are kept per translation unit so a run can be
# diffed against an earlier baseline.

set -uo pipefail

usage() {
    cat <<'USAGE'
Usage: dev/run-julia-gc-analyzer-all.sh BUILD_DIR [LOG_DIR]

Analyze all of src/*.c and src/*.cc, except the files tied to other garbage
collectors, and write one log per translation unit into LOG_DIR
(default: gc-analysis).

Environment overrides:
  JULIA_GC_ANALYZER_JOBS      parallel jobs (default: number of CPUs)
  JULIA_GC_ANALYZER_CHECKERS  analyzer checker list, as for the single-file script
USAGE
}

here=$(cd "$(dirname "$0")/.." && pwd)

# Worker mode, used by the xargs fan-out below.
if [[ ${1:-} == --analyze-one ]]; then
    cd "$here"
    src=$4
    log="$3/$(basename "$src").log"
    # The compiled-code corpus lives outside src/ and includes "compiled.h"
    case $src in
        tst/test-compile/*) export JULIA_GC_ANALYZER_CFLAGS="-I src" ;;
    esac
    if dev/run-julia-gc-analyzer.sh "$2" "$src" > "$log" 2>&1; then
        printf '  ok    %s\n' "$src"
    else
        printf '  FAIL  %s\n' "$src"
        # The logs carry ANSI colour codes, so record failures here rather
        # than trying to grep them back out afterwards.
        printf '%s\n' "$src" >> "$3/failed"
    fi
    exit 0
fi

if [[ $# -lt 1 || $# -gt 2 ]]; then
    usage >&2
    exit 1
fi

build_dir=$1
log_dir=${2:-gc-analysis}
jobs=${JULIA_GC_ANALYZER_JOBS:-$(getconf _NPROCESSORS_ONLN 2>/dev/null || echo 4)}

# These implement or support other garbage collectors and are not part of the
# Julia-GC build.
EXCLUDE=(boehm_gc.c gasman.c sysmem.c)

cd "$here"
mkdir -p "$log_dir"
# clear previous results: a stale log is indistinguishable from a fresh one
rm -f "$log_dir/failed" "$log_dir"/*.log

sources=()
for f in src/*.c src/*.cc; do
    base=$(basename "$f")
    skip=
    for e in "${EXCLUDE[@]}"; do
        [[ $base == "$e" ]] && skip=1
    done
    [[ -n $skip ]] || sources+=("$f")
done

# GAP's compiler emits C that must root its own locals, and the checked-in
# expected outputs of tst/test-compile are a stable sample of what it emits.
# Analyzing them turns a codegen regression into a diagnostic here rather
# than an intermittent crash much later.
for f in tst/test-compile/*.dynamic.c; do
    [[ -e $f ]] && sources+=("$f")
done

echo "Analyzing ${#sources[@]} translation units with $jobs job(s) into $log_dir/"

# The per-file runner picks the default checker list; an explicit
# JULIA_GC_ANALYZER_CHECKERS in the environment reaches it either way.

printf '%s\n' "${sources[@]}" \
    | xargs -P "$jobs" -n 1 "$0" --analyze-one "$build_dir" "$log_dir"

echo
echo "=== translation units with diagnostics ==="
if [[ -s "$log_dir/failed" ]]; then
    sort "$log_dir/failed" | sed 's|^|  |'
    echo
    echo "Logs are in $log_dir/; strip the colour codes to read them, e.g."
    echo "  sed 's/\x1b\[[0-9;]*m//g' $log_dir/NAME.log | grep -E 'error:|warning:'"
    exit 1
fi
echo "  (none)"
