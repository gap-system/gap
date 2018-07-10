#!/usr/bin/env bash
# zlib on Cygwin requires a special build procedure 
# The following is taken from the zlib package in Cygwin

cd extern/zlib &&
make -f win32/Makefile.gcc \
		SHAREDLIB=cygz.dll IMPLIB=libz.dll.a \
		SHARED_MODE=1 \
		prefix= \
		BINARY_PATH=../install/zlib/bin \
		INCLUDE_PATH=../install/zlib/include \
		LIBRARY_PATH=../install/zlib/lib \
        all install
