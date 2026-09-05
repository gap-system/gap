#!/usr/bin/env bash
#
# This script is used by the build system to build external dependencies
# such as GMP and Boehm GC in a controlled and uniform way

set -e

echo "=== START building $pkg ==="

# read arguments (TODO: error handling)
pkg=$1; shift
src=$1; shift # directory with package sources -- must be an absolute path

# when cross-compiling (detected via differing --build and --host among the
# configure flags), the test binaries built by `make check` cannot run
build_triple=
host_triple=
for arg in "$@"; do
  case "$arg" in
    --build=*) build_triple=${arg#--build=} ;;
    --host=*)  host_triple=${arg#--host=} ;;
  esac
done
skip_check=no
if [[ -n "$host_triple" && "$host_triple" != "$build_triple" ]]; then
  skip_check=yes
fi

builddir=extern/build/$pkg
prefix="$PWD/extern/install/$pkg"

mkdir -p "$builddir"

# If the subproject's configure was modified, or if GAP's configure was
# run more recently, we re-run the subproject configure.
if [[ ( ! "$builddir/config.status" -nt "$src/configure" )
    || ( "config.status" -nt "$builddir/config.status" ) ]] ; then
  pushd "$builddir"
  "$src/configure" --prefix="$prefix" "$@"
  popd
fi

$MAKE -C "$builddir"
if [[ "$skip_check" = yes ]]; then
  echo "=== SKIPPING check for $pkg (cross-compiling) ==="
elif ! $MAKE -C "$builddir" check; then
  echo "=== FAILED checking $pkg ==="
  echo "The copy of $pkg distributed with GAP has failed to pass its internal checks"
  echo "You can either install the library from a different source, or use"
  echo "a newer release of GAP"
  exit 1
fi

$MAKE -C "$builddir" install

# TODO: insert command to check whether make needs to be called at all?
echo "=== DONE building $pkg ==="
exit 0
