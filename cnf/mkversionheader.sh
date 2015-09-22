#!/bin/sh -ex

TMP="$1".tmp
DST="$1"

# Determine build version and date
GAP_BUILD_VERSION=`git describe --tags --dirty || echo`
GAP_BUILD_DATE=`date +"%Y-%m-%d %H:%M:%S (%Z)"`
if test x"${GAP_BUILD_VERSION}" = x ; then
  GAP_BUILD_VERSION=unknown
fi

# Generate the file
cat > "$TMP" <<EOF
#ifndef GAP_BUILD_VERSION
#define GAP_BUILD_VERSION  "$GAP_BUILD_VERSION"
#define GAP_BUILD_DATETIME "$GAP_BUILD_DATE"
#endif
EOF

# Only copy the header over if there were any changes, to
# avoid pointless recompiles.
if ! cmp -s $TMP $DST ; then
  cp "$TMP" "$DST"
fi;

rm $TMP
