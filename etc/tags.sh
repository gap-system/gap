#!/bin/sh

set -ex

#
# This little script tries guessing which executable
# in the system is exuberant ctags. It first checks whether
# the environment variable $GAP_CTAGS is set, and if so, executes
# the command given by it, otherwise it first tries locating
# `exctags`, and then `ctags`.
#

for tags in "$GAP_CTAGS" exctags ctags-exuberant ctags
do
    command -v "$tags" >/dev/null 2>&1 || continue
    echo "$tags" "$@"
    exec "$tags" "$@"
done

echo "error, exuberant ctags not found"
exit 1
