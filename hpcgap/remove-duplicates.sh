#!/bin/sh -e
#
# Find and remove any files which are identical in the root GAP
# directory and the hpcgap subdirectory.
#
find . -type f -exec cmp -s ../{} {} \; -print0 | xargs -0 git rm --quiet --force
