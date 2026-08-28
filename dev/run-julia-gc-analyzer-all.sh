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
rm -f "$log_dir/failed"

sources=()
for f in src/*.c src/*.cc; do
    base=$(basename "$f")
    skip=
    for e in "${EXCLUDE[@]}"; do
        [[ $base == "$e" ]] && skip=1
    done
    [[ -n $skip ]] || sources+=("$f")
done

echo "Analyzing ${#sources[@]} translation units with $jobs job(s) into $log_dir/"

export JULIA_GC_ANALYZER_CHECKERS=${JULIA_GC_ANALYZER_CHECKERS:-julia.GCChecker}

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
