#!/bin/sh
#
# This script expects a single argument, which should be an URL pointing to a
# file for download; it then tries to download that file, into a local file
# with the same name as the remote file.
set -e

# check whether curl is available, and if so, delegate to it
command -v curl >/dev/null 2>&1 && exec curl -L -O "$@"

# check whether wget is available, and if so, delegate to it
command -v wget >/dev/null 2>&1 && exec wget -N "$@"

# if no supported download tool is available, abort
echo "Error, failed to download: neither wget nor curl available"
exit 1
