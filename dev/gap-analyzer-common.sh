# Shared setup for the GAP static-analysis helper scripts. Sourced, not run.
#
# Reads the compile flags recorded in an out-of-tree GAP build directory and
# locates the clang and analyzer plugin from the Julia checkout that build was
# configured against.
#
# Callers set $build_dir and $source_file, then call analyzer_setup; it sets
# $lang, $clang_bin, $plugin, $cflags_array and $cppflags_array, plus
# $clang_tidy_bin and $first_decl_plugin for the first-declaration check.
#
# Nothing here is hardcoded to a particular checkout: the Julia tree is found
# from what configure recorded in the build directory. Override any of it with
# JULIA_INCLUDE_DIR, JULIA_GC_ANALYZER_CLANG, JULIA_GC_ANALYZER_PLUGIN,
# JULIA_CLANG_TIDY or JULIA_FIRST_DECL_PLUGIN.

# The checker list Julia itself uses (CLANGSA_GC_CHECKERS in its src/Makefile).
# Running julia.GCChecker on its own is not a supported configuration: without
# core, paths are not terminated at noreturn calls, which produces spurious
# "JL_GC_POP without corresponding push" reports.
GAP_ANALYZER_DEFAULT_CHECKERS="core,julia.GCChecker,apiModeling,unix.cstring.CStringModeling,unix.DynamicMemoryModeling,nullability.NullPassedToNonnull,nullability.NullReturnedFromNonnull"

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

# Locate an analyzer plugin by base name, e.g. libGCCheckerPlugin.
find_plugin_named() {
    local julia_root=$1 base=$2
    find "$julia_root" \( -name "$base*.dylib" -o -name "$base*.so" \) \
        2>/dev/null | head -n 1
}

find_plugin() {
    find_plugin_named "$1" libGCCheckerPlugin
}

find_first_decl_plugin() {
    find_plugin_named "$1" libFirstDeclAnnotationsPlugin
}

find_clang_tidy() {
    local julia_root=$1
    find "$julia_root" \( -path '*/usr/tools/clang-tidy' -o -path '*/bin/clang-tidy' \) \
        2>/dev/null | head -n 1
}

find_clang() {
    local julia_root=$1
    find "$julia_root" \( -path '*/usr/tools/clang' -o -path '*/bin/clang' \) \
        2>/dev/null | head -n 1
}

# The build directory's flag files carry include paths relative to that
# directory (-I./build, -I../../src/extra); clang runs from the source
# directory, so make them absolute.
absolutize_includes() {
    local build_dir=$1 var=$2 i token path
    local -n arr=$var
    for ((i = 0; i < ${#arr[@]}; ++i)); do
        token=${arr[$i]}
        if [[ $token == -I* ]] && [[ ${token#-I} != /* ]]; then
            path=${token#-I}
            arr[$i]="-I$(cd "$build_dir/$path" 2>/dev/null && pwd || echo "$path")"
        elif [[ $token == "-isystem" ]] && (( i + 1 < ${#arr[@]} )) && [[ ${arr[$((i + 1))]} != /* ]]; then
            path=${arr[$((i + 1))]}
            arr[$((i + 1))]=$(cd "$build_dir/$path" 2>/dev/null && pwd || echo "$path")
        fi
    done
}

analyzer_setup() {
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

    lang=c
    case "$source_file" in
        *.cc | *.cpp | *.cxx)
            lang=c++
            ;;
    esac

    local cppflags cflags julia_include julia_root
    cppflags=$(cat "$build_dir/cnf/GAP-CPPFLAGS")
    if [[ $lang == c++ ]]; then
        cflags=$(cat "$build_dir/cnf/GAP-CXXFLAGS")
    else
        cflags=$(cat "$build_dir/cnf/GAP-CFLAGS")
    fi

    # configure records the Julia the build was configured against
    julia_include=${JULIA_INCLUDE_DIR:-$(sed -n 's/^JULIA_INCLUDEDIR = //p' "$build_dir/GNUmakefile")}
    if [[ -z ${julia_include:-} ]]; then
        echo "error: $build_dir/GNUmakefile records no Julia; configure it with --with-gc=julia" >&2
        exit 1
    fi

    # The analyzer plugins and Julia's clang come from a Julia source checkout.
    # configure points dev/julia in the build directory at it when the Julia
    # it was given is one; a dev/julia in the source tree serves as well.
    # Otherwise the configured Julia is assumed to be such a checkout's usr/.
    local src_dir
    src_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
    if [[ -d "$build_dir/dev/julia/src" ]]; then
        julia_root=$(cd "$build_dir/dev/julia" && pwd -P)
    elif [[ -d "$src_dir/dev/julia/src" ]]; then
        julia_root=$(cd "$src_dir/dev/julia" && pwd -P)
    else
        julia_root=$(cd "$julia_include/../.." && pwd)
    fi
    plugin=${JULIA_GC_ANALYZER_PLUGIN:-$(find_plugin "$julia_root")}
    clang_bin=${JULIA_GC_ANALYZER_CLANG:-$(find_clang "$julia_root")}
    first_decl_plugin=${JULIA_FIRST_DECL_PLUGIN:-$(find_first_decl_plugin "$julia_root")}
    clang_tidy_bin=${JULIA_CLANG_TIDY:-$(find_clang_tidy "$julia_root")}

    if [[ -z ${clang_bin:-} ]]; then
        if command -v clang >/dev/null 2>&1; then
            clang_bin=$(command -v clang)
        else
            cat >&2 <<EOM
error: could not find a clang binary under $julia_root or on PATH

Set JULIA_GC_ANALYZER_CLANG explicitly.
EOM
            exit 1
        fi
    fi

    split_shell_words "$cflags" cflags_array
    split_shell_words "$cppflags" cppflags_array
    absolutize_includes "$build_dir" cppflags_array
}

# Prepend the macOS SDK path, which Julia's clang does not find on its own.
add_sysroot() {
    local -n cmd_ref=$1
    if [[ $(uname -s) == Darwin ]]; then
        local sdk_path
        sdk_path=$(xcrun --show-sdk-path --sdk macosx)
        cmd_ref=("${cmd_ref[0]}" -isysroot "$sdk_path" "${cmd_ref[@]:1}")
    fi
}

run_analysis() {
    local -n cmd_ref=$1
    printf 'Running:'
    printf ' %q' "${cmd_ref[@]}"
    printf '\n'
    exec "${cmd_ref[@]}"
}
