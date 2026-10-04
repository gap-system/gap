#!/usr/bin/env bash

# Julia's first-declaration check, run over GAP sources.
#
# Clang silently ignores an annotation that appears only on a later declaration
# of a function, so one written on a definition whose header already declares
# the function does nothing at all. This check reports that, and also reports
# functions assigned to a Julia callback type requiring JL_NOTSAFEPOINT without
# carrying the annotation themselves.

set -euo pipefail

usage() {
    cat <<'USAGE'
Usage: dev/run-first-decl-check.sh BUILD_DIR SOURCE...

Check where Julia annotations sit on GAP declarations, using the compile flags
recorded in an out-of-tree GAP build directory. Passing several sources checks
each in turn and reports a combined count.

Example:
  dev/run-first-decl-check.sh out-of-tree/julia-dev src/julia_gc.c
  dev/run-first-decl-check.sh out-of-tree/julia-dev src/*.c src/*.cc

Environment overrides:
  JULIA_CLANG_TIDY          path to clang-tidy to use
  JULIA_FIRST_DECL_PLUGIN   path to libFirstDeclAnnotationsPlugin
USAGE
}

if [[ $# -lt 2 ]]; then
    usage >&2
    exit 1
fi

. "$(dirname "$0")/gap-analyzer-common.sh"

build_dir=$1
shift

status=0
total=0

for source_file in "$@"; do
    analyzer_setup

    if [[ -z ${clang_tidy_bin:-} ]]; then
        echo "error: could not find clang-tidy; set JULIA_CLANG_TIDY" >&2
        exit 1
    fi
    if [[ -z ${first_decl_plugin:-} ]]; then
        cat >&2 <<EOM
error: could not find libFirstDeclAnnotationsPlugin

Build it in the Julia checkout with 'make -C src clangsa', or point at it
with JULIA_FIRST_DECL_PLUGIN.
EOM
        exit 1
    fi

    cmd=(
        "$clang_tidy_bin"
        "$source_file"
        -header-filter='.*'
        --quiet
        -load "$first_decl_plugin"
        --checks='-*,julia-first-decl-annotations'
        --
        -D__clang_gcanalyzer__
        "${cflags_array[@]}"
        "${cppflags_array[@]}"
        -fno-color-diagnostics
        -x "$lang"
    )
    # Unlike clang, clang-tidy only accepts compiler flags after the '--',
    # so the sysroot goes at the end rather than through add_sysroot.
    if [[ $(uname -s) == Darwin ]]; then
        cmd+=(-isysroot "$(xcrun --show-sdk-path --sdk macosx)")
    fi

    out=$("${cmd[@]}" 2>&1) || true
    if grep -q '^error: clang-tidy:' <<<"$out"; then
        printf '%s\n' "$out" >&2
        exit 1
    fi
    n=$(grep -c 'julia-first-decl-annotations' <<<"$out" || true)
    if (( n > 0 )); then
        printf '%s\n' "$out" | grep 'julia-first-decl-annotations'
        total=$((total + n))
        status=1
    fi
done

if (( total > 0 )); then
    echo "--- $total first-declaration finding(s)" >&2
fi
exit $status
