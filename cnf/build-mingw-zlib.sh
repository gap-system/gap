#!/usr/bin/env bash
# zlib on MinGW requires a special build procedure
# Build only static library to avoid cross-compilation linking issues

cd extern/zlib &&

# Build static library first
make -f win32/Makefile.gcc \
		CC="${CC}" \
		libz.a &&

# Install static library and headers
mkdir -p ../install/zlib/lib ../install/zlib/include &&
cp libz.a ../install/zlib/lib/ &&
cp zlib.h zconf.h ../install/zlib/include/