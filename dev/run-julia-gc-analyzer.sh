#!/usr/bin/env bash

set -euo pipefail

usage() {
    cat <<'EOF'
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
EOF
}

if [[ $# -ne 2 ]]; then
    usage >&2
    exit 1
fi

build_dir=$1
source_file=$2

if [[ ! -d "$build_dir" ]]; then
    echo "error: build dir not found: $build_dir" >&2
    exit 1
fi

if [[ ! -f "$source_file" ]]; then
    echo "error: source file not found: $source_file" >&2
    exit 1
fi

if [[ ! -f "$build_dir/cnf/GAP-CFLAGS" ]] || [[ ! -f "$build_dir/cnf/GAP-CXXFLAGS" ]] || [[ ! -f "$build_dir/cnf/GAP-CPPFLAGS" ]]; then
    echo "error: $build_dir does not look like a configured GAP build dir" >&2
    exit 1
fi

read_flags() {
    local path=$1
    cat "$path"
}

split_shell_words() {
    local value=$1
    local -n out_ref=$2
    eval "out_ref=($value)"
}

unquote() {
    local value=$1
    value=${value#\'}
    value=${value%\'}
    value=${value#\"}
    value=${value%\"}
    printf '%s\n' "$value"
}

find_plugin() {
    local julia_root=$1
    find "$julia_root" -name 'libGCCheckerPlugin*.dylib' -o -name 'libGCCheckerPlugin*.so' 2>/dev/null | head -n 1
}

find_clang() {
    local julia_root=$1
    find "$julia_root" \( -path '*/usr/tools/clang' -o -path '*/bin/clang' \) \
        2>/dev/null | head -n 1
}

extract_julia_include() {
    local cflags=$1
    local token next
    local -a tokens
    split_shell_words "$cflags" tokens
    for ((i = 0; i < ${#tokens[@]}; ++i)); do
        token=${tokens[$i]}
        if [[ $token == -I* ]]; then
            next=${token#-I}
            if [[ $next == *"/include/julia"* ]]; then
                unquote "$next"
                return 0
            fi
        elif [[ $token == "-isystem" ]] && (( i + 1 < ${#tokens[@]} )); then
            next=${tokens[$((i + 1))]}
            if [[ $next == *"/include/julia"* ]]; then
                unquote "$next"
                return 0
            fi
        fi
    done
    return 1
}

lang=c
case "$source_file" in
    *.cc | *.cpp | *.cxx)
        lang=c++
        ;;
esac

cppflags=$(read_flags "$build_dir/cnf/GAP-CPPFLAGS")
cflags_c=$(read_flags "$build_dir/cnf/GAP-CFLAGS")
if [[ $lang == c++ ]]; then
    cflags=$(read_flags "$build_dir/cnf/GAP-CXXFLAGS")
else
    cflags=$cflags_c
fi

julia_include=${JULIA_INCLUDE_DIR:-$(extract_julia_include "$cflags $cppflags $cflags_c" || true)}
if [[ -z ${julia_include:-} ]]; then
    echo "error: could not infer Julia include dir from build flags" >&2
    exit 1
fi

julia_root=$(cd "$julia_include/../.." && pwd)
plugin=${JULIA_GC_ANALYZER_PLUGIN:-$(find_plugin "$julia_root")}
clang_bin=${JULIA_GC_ANALYZER_CLANG:-$(find_clang "$julia_root")}

if [[ -z ${plugin:-} ]]; then
    cat >&2 <<EOF
error: could not find libGCCheckerPlugin under $julia_root

Set JULIA_GC_ANALYZER_PLUGIN explicitly, or build Julia's GC analyzer plugin
first (for example via the Julia tree's analysis targets).
EOF
    exit 1
fi

if [[ -z ${clang_bin:-} ]]; then
    if command -v clang >/dev/null 2>&1; then
        clang_bin=$(command -v clang)
    else
        cat >&2 <<EOF
error: could not find a clang binary under $julia_root or on PATH

Set JULIA_GC_ANALYZER_CLANG explicitly.
EOF
        exit 1
    fi
fi

split_shell_words "$cflags" cflags_array
split_shell_words "$cppflags" cppflags_array

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

if [[ $(uname -s) == Darwin ]]; then
    sdk_path=$(xcrun --show-sdk-path --sdk macosx)
    cmd=(
        "$clang_bin"
        -isysroot "$sdk_path"
        "${cmd[@]:1}"
    )
fi

printf 'Running:'
printf ' %q' "${cmd[@]}"
printf '\n'

exec "${cmd[@]}"
