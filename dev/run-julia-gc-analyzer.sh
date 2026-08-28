#!/usr/bin/env bash

set -euo pipefail

usage() {
    cat <<'USAGE'
Usage: dev/run-julia-gc-analyzer.sh BUILD_DIR SOURCE

Run Julia's GC static analyzer on one GAP C/C++ source file using the compile
flags recorded in an out-of-tree GAP build directory.

Examples:
  dev/run-julia-gc-analyzer.sh out-of-tree/julia-dev src/julia_gc.c
  dev/run-julia-gc-analyzer.sh out-of-tree/julia-dev-debug src/objects.c

Environment overrides:
  JULIA_GC_ANALYZER_CLANG   path to clang to use
  JULIA_GC_ANALYZER_PLUGIN  path to libGCCheckerPlugin shared library
  JULIA_GC_ANALYZER_CHECKERS analyzer checker list
USAGE
}

if [[ $# -ne 2 ]]; then
    usage >&2
    exit 1
fi

. "$(dirname "$0")/gap-analyzer-common.sh"

build_dir=$1
source_file=$2

analyzer_setup

if [[ -z ${plugin:-} ]]; then
    cat >&2 <<EOM
error: could not find libGCCheckerPlugin under the Julia checkout

Set JULIA_GC_ANALYZER_PLUGIN explicitly, or build Julia's GC analyzer plugin
first with 'make -C dev/julia/src clangsa'.
EOM
    exit 1
fi

checkers=${JULIA_GC_ANALYZER_CHECKERS:-core,julia.GCChecker}

cmd=(
    "$clang_bin"
    -D__clang_gcanalyzer__
    --analyze
    -Xanalyzer -analyzer-werror
    -Xanalyzer -analyzer-output=text
    --analyzer-no-default-checks
    -Xclang -load
    -Xclang "$plugin"
    -Xclang "-analyzer-checker=${checkers}"
    "${cflags_array[@]}"
    "${cppflags_array[@]}"
    -fcolor-diagnostics
    -x "$lang"
    "$source_file"
)

add_sysroot cmd
run_analysis cmd
