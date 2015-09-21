#!/bin/sh

GAP_BUILD_VERSION=`git describe --tags --dirty`
GAP_BUILD_DATE=`date +"%Y-%m-%d %H:%M:%SZ"`
if test x"${GAP_BUILD_VERSION}" != x ; then
cat > $1 <<EOF
#ifndef GAP_BUILD_VERSION
#define GAP_BUILD_VERSION  "$GAP_BUILD_VERSION"
#define GAP_BUILD_DATETIME "$GAP_BUILD_DATE"
#endif
EOF
else
cat > $1 <<EOF
#ifndef GAP_BUILD_VERSION
#define GAP_BUILD_VERSION  "none"
#define GAP_BUILD_DATETIME "$GAP_BUILD_DATE"
#endif
EOF
fi
