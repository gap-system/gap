#!/bin/sh

GAP_BUILD_VERSION=`git describe --tags --dirty`

if test x"${GAP_BUILD_VERSION}" != x ; then
cat > $1 <<EOF
#ifndef GAP_BUILD_VERSION
#define GAP_BUILD_VERSION "$GAP_BUILD_VERSION"
#endif
EOF
else
cat > $1 <<EOF
#ifndef GAP_BUILD_VERSION
#define GAP_BUILD_VERSION "none"
#endif
EOF
fi
