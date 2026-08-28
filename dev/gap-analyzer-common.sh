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
# from the -I flag recorded in the build directory. Override any of it with
# JULIA_INCLUDE_DIR, JULIA_GC_ANALYZER_CLANG, JULIA_GC_ANALYZER_PLUGIN,
# JULIA_CLANG_TIDY or JULIA_FIRST_DECL_PLUGIN.

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

    local cppflags cflags cflags_c julia_include julia_root
    cppflags=$(cat "$build_dir/cnf/GAP-CPPFLAGS")
    cflags_c=$(cat "$build_dir/cnf/GAP-CFLAGS")
    if [[ $lang == c++ ]]; then
        cflags=$(cat "$build_dir/cnf/GAP-CXXFLAGS")
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
