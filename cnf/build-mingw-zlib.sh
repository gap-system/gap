#!/usr/bin/env bash
# zlib's configure script does not support mingw hosts; use the win32
# makefile that zlib ships instead. Only a static libz.a is built.

set -e

cd extern/zlib &&
make -f win32/Makefile.gcc \
		CC="${CC:-gcc}" \
		SHARED_MODE=0 \
		prefix= \
		BINARY_PATH=../install/zlib/bin \
		INCLUDE_PATH=../install/zlib/include \
		LIBRARY_PATH=../install/zlib/lib \
		libz.a install
