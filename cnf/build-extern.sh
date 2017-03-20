#!/usr/bin/env bash
#
# This script is used by the build system to build external dependencies
# such as GMP and Boehm GC in a controlled and uniform way

set -e

echo "=== START building $pkg ==="

# read arguments (TODO: error handling)
pkg=$1; shift
src=$1; shift # directory with package sources -- must be an absolute path

builddir=extern/build/$pkg
prefix=$PWD/extern/install/$pkg

mkdir -p "$builddir"

# If the subproject's configure was modified, or if GAP's configure was
# run more recently, we re-run the subproject configure.
if [[ ( ! "$builddir/config.status" -nt "$src/configure" )
    || ( "config.status" -nt "$builddir/config.status" ) ]] ; then
  pushd "$builddir"
  "$src/configure" --prefix=$prefix "$@"
  popd
fi

$MAKE -C "$builddir"
$MAKE -C "$builddir" install

# TODO: insert command to check whether make needs to be called at all?
echo "=== DONE building $pkg ==="
