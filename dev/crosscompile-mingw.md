# Cross-compiling GAP for native Windows (mingw-w64)

Status: the kernel compiles and links (see issue #4157); the resulting
`gap.exe` does not run yet. The canonical target is x86_64-w64-mingw32,
matching the MSYS2 MINGW64 environment used by the CI job `mingw64`.

The instructions below are for macOS; on Linux, install `gcc-mingw-w64`
instead of the brew package and adjust paths.

## Toolchain and dependencies

```sh
brew install mingw-w64 autoconf automake libtool

# prefix for the cross-compiled dependencies
export MPREFIX=$HOME/opt/x86_64-w64-mingw32

# GMP: use the copy bundled with GAP (or any gmp release tarball).
# -std=gnu17 works around GMP 6.3 configure tests that break with the
# C23 default of GCC >= 15.
cd extern/gmp
CC="x86_64-w64-mingw32-gcc -std=gnu17" ./configure \
    --build=$(./config.guess) --host=x86_64-w64-mingw32 \
    --prefix=$MPREFIX --disable-shared --enable-static
make -j8 && make install    # no 'make check': cross binaries cannot run
cd ../..

# zlib: its configure does not support mingw, use the win32 makefile
cd extern/zlib
make -f win32/Makefile.gcc PREFIX=x86_64-w64-mingw32- SHARED_MODE=0 \
    INCLUDE_PATH=$MPREFIX/include LIBRARY_PATH=$MPREFIX/lib \
    BINARY_PATH=$MPREFIX/bin libz.a install
git checkout . && git clean -fdx .    # remove in-tree build artifacts
cd ../..
```

## Seeding the generated files

The build runs two just-built programs: `ffgen` and `build/gap-nocomp`
(the latter generates `build/c_oper1.c` and `build/c_type1.c`). When
cross-compiling, configure picks a build-machine compiler for `ffgen`
(override it with `CC_FOR_BUILD=...`), but the `c_*.c` files must be
seeded from a native build (their content is target independent on
64-bit systems):

```sh
./autogen.sh
mkdir -p build-native && cd build-native
../configure && make -j8
cd ..
cp build-native/build/{ffdata.c,ffdata.h,c_oper1.c,c_type1.c} src/
```

Files placed in `src/` under these names override the generated ones
(see `Makefile.rules`); they are `.gitignore`d.

## Cross-compiling GAP

```sh
mkdir -p build-mingw64 && cd build-mingw64
../configure --build=$(../cnf/config.guess) --host=x86_64-w64-mingw32 \
    --with-gmp=$MPREFIX --with-zlib=$MPREFIX --without-readline
make -j8
```

Verify:

```sh
file gap.exe                # PE32+ executable (console) x86-64
x86_64-w64-mingw32-objdump -p gap.exe | grep 'DLL Name'
                            # only system DLLs + libwinpthread-1.dll
```

`wine gap.exe --version` works as a smoke test (copy
`libwinpthread-1.dll` from the toolchain next to gap.exe first);
anything beyond `--version` needs the runtime port.
