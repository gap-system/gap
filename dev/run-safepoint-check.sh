#!/usr/bin/env bash

# Clang Thread Safety Analysis of GAP's safepoint annotations, the counterpart
# to Julia's own 'make -C src safesrc'. Unlike the GC checker this analysis has
# no implicit default: every function that can reach a safepoint must say so
# with GAP_GC_CANSAFEPOINT, so a function without it is flagged as soon as it
# calls one that has it.

set -euo pipefail

usage() {
    cat <<'USAGE'
Usage: dev/run-safepoint-check.sh BUILD_DIR SOURCE

Check one GAP C/C++ source file's safepoint annotations using the compile flags
recorded in an out-of-tree GAP build directory.

Example:
  dev/run-safepoint-check.sh out-of-tree/julia-dev src/julia_gc.c

Environment overrides:
  JULIA_GC_ANALYZER_CLANG   path to clang to use
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

cmd=(
    "$clang_bin"
    -D__clang_safetyanalysis__
    -fsyntax-only
    -Wthread-safety
    -Wthread-safety-negative
    -Werror=thread-safety
    # GAP_GC_CANSAFEPOINT expands to a requires_capability attribute, which
    # clang's thread-safety analysis accepts on functions and parameters but
    # not on a function-pointer typedef. Julia suppresses the same two
    # warnings for the same reason.
    -Wno-ignored-attributes
    -Wno-thread-safety-attributes
    "${cflags_array[@]}"
    "${cppflags_array[@]}"
    -fcolor-diagnostics
    -x "$lang"
    "$source_file"
)

add_sysroot cmd
run_analysis cmd
