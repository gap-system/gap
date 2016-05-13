#!/bin/sh
#
# Find and remove any files which are identical in the root GAP
# directory and the hpc subdirectory.
#
# Must be run from inside the hpc directory!
find . -type f -exec cmp -s ../{} {} \; -print0 | xargs -0 git rm
