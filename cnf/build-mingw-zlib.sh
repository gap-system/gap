#!/usr/bin/env bash
# zlib on MinGW requires a special build procedure
# Build static library with proper cross-compilation

cd extern/zlib &&

# Extract prefix from CC (e.g., "x86_64-w64-mingw32-gcc " -> "x86_64-w64-mingw32-")
PREFIX=$(echo "${CC}" | sed 's/gcc.*$//')

# Build static library with cross-compiler
make -f win32/Makefile.gcc \
		CC="${CC}" \
		PREFIX="${PREFIX}" \
		libz.a &&

# Install static library and headers
mkdir -p ../install/zlib/lib ../install/zlib/include &&
cp libz.a ../install/zlib/lib/ &&
cp zlib.h zconf.h ../install/zlib/include/