#!/usr/bin/env bash

set -eux

BASEDIR="$(pwd)"

if ! command -v emmake &> /dev/null; then
    echo Please install, and source, emscripten
    echo This script was tested with version 3.1.23
    echo See https://emscripten.org/docs/getting_started/downloads.html for install instructions
    exit 1
fi;

# Build the configure script if this is a fresh git checkout
if [[ ! -f ./configure ]]; then
    ./autogen.sh
fi

# First build a standard GAP install, for some files
# we will need during building
(
    mkdir -p native-build
    cd native-build
    if [[ ! -f config.status ]]; then
        ../configure
    fi
    make -j8
)

AUX_BUILD=$PWD/extern/emscripten/build
AUX_PREFIX=$PWD/extern/emscripten/install

mkdir -p "$AUX_BUILD"
mkdir -p "$AUX_PREFIX"

(
    mkdir -p "$AUX_BUILD/gmp"
    cd "$AUX_BUILD/gmp" &&
    if [[ ! -f config.status ]]; then
        CC_FOR_BUILD=/usr/bin/gcc ABI=standard \
        emconfigure $BASEDIR/extern/gmp/configure \
        --build i686-pc-linux-gnu --host none \
        --disable-assembly --enable-cxx \
        --prefix=$AUX_PREFIX
    fi &&
    emmake make -j8 &&
    emmake make install
)

(
    mkdir -p "$AUX_BUILD/zlib"
    cd "$AUX_BUILD/zlib" &&
    if [[ ! -f Makefile ]]; then
        emconfigure $BASEDIR/extern/zlib/configure --prefix=$AUX_PREFIX
    fi;
    emmake make -j8 &&
    emmake make install
)

# There are two problems with building GAP
# 1) GAP builds some executables (ffgen and gap-nocomp), which it wants to
#    execute while building. We get these files from 'native-build'.
# 2) 'configure' gets confused by some of the LDFLAGS we need, so we have to pass
#     them in to 'make'
#
# These options are:
# -sASYNCIFY -- we don't care about ASYNC, but this forces the compiler to output
# all variables onto the stack, which is required for GASMAN
# Note we could use 'ALLOW_MEMORY_GROWTH', both we don't currently, we instead set
# a big memory window.
# -O2 : Some optimisation
# EXEEXT=.html -- this is actually a GAP makefile option, it lets us make the
# output 'gap.html', which makes emscripten output a html page we can load
# --pre-js lazy_fs.js : Prepend lazy_fs.js that is generated for lazy loading

# Run configure if we don't have a makefile, or someone configured this
# GAP for standard building (emscripten builds will use 'emcc')
if [[ ! -f GNUmakefile ]] || ! grep '/emcc' GNUmakefile > /dev/null; then
    emconfigure ./configure ABI=32 \
    --with-gmp=$AUX_PREFIX \
    --with-zlib=$AUX_PREFIX \
    LDFLAGS="-s ASYNCIFY=1 -O2"
fi;

# Get full required packages
emmake make bootstrap-pkg-full

# Copy in files from native_build
cp native-build/build/c_*.c native-build/build/ffdata.* src/

# Generate lazy_fs.js for lazy loading
cat << 'EOF' > lazy_fs.js
Module.preRun = Module.preRun || [];
Module.preRun.push(function() {
    var files = [
EOF

# Dynamically find and append ALL required files to the JS array
# The flag -type f is safe because the only symbolic link is 'tst/mockpkg/Makefile.gappkg',
# which is safe to ignore
find pkg lib grp tst doc hpcgap dev benchmark -type f | sed -e 's/.*/        "&",/' >> lazy_fs.js

cat << 'EOF' >> lazy_fs.js
    ];
    
    var createdDirs = {};
    files.forEach(function(file) {
        var parts = file.split('/');
        var name = parts.pop();
        var parent = '/' + parts.join('/');
        
        // Create the directory structure if it doesn't exist
        if (!createdDirs[parent]) {
            try {
                FS.mkdirTree(parent);
            } catch(e) {} 
            createdDirs[parent] = true;
        }
        
        // Map the file lazily
        FS.createLazyFile(parent, name, file, true, false);
    });
});
EOF

# The EXEEXT is usually for windows, but here it lets us set GAP's extension,
# which lets us produce a html page to run GAP in.
emmake make -j8 LDFLAGS="--pre-js lazy_fs.js -s ASYNCIFY=1 -sTOTAL_STACK=32mb -sASYNCIFY_STACK_SIZE=32000000 -sINITIAL_MEMORY=2048mb -O2" EXEEXT=".html"
