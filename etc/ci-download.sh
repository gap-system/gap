#!/usr/bin/env bash
#
# This script expects a single argument, which should be an URL pointing to a
# file for download; it then tries to download that file, into a local file
# with the same name as the remote file.
# If a file of the same name exists in ~/.gap-package-cache, then this file
# is used if it has the same hash
set -e

PACKAGEDIR=~/.gap-package-cache

# Get the name of the file we are downloading (everything after the final /)
name=${*##*/}

# Check if file already exists and has right hash
if [ -f ${PACKAGEDIR}/"${name}" ] ; then
    command -v sha256sum > /dev/null 2>&1 &&
    {
        hash1=$(curl --retry 5 --retry-delay 5 --max-time 10 -L "$*.sha256")
        hash2=$(sha256sum ${PACKAGEDIR}/"${name}" | cut -d' ' -f1)
        if [ "x$hash1" == "x$hash2" ] ; then
            echo "Getting file from cache"
            cp ${PACKAGEDIR}/"${name}" .
            exit 0
        fi
    }
fi

if curl -L --retry 5 --retry-delay 5 --max-time 120 -O "$*" ; then
    if [ -d ${PACKAGEDIR} ]; then
        cp "${name}" ${PACKAGEDIR}
    fi
    exit 0
fi
exit 1
