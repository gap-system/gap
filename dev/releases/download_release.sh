#!/bin/sh
set -ex

# invoke this like so:
#  ./download_release.sh  4.14.0

VER=$1
[ x"$VER" != x ] || exit 1
echo "Downloading files for release $VER"

cd ~/http               # follow symlink to target directory
mkdir -p gap-${VER%.*}  # ensure directories are present
cd gap-${VER%.*}
mkdir -p exe zip tar.gz

# now download all gap-$VER* files in the release into the appropriate subdirectories
BASEURL=https://github.com/gap-system/gap/releases/download/v${VER}

cd exe
wget ${BASEURL}/gap-${VER}-x86_64.exe.sha256
wget ${BASEURL}/gap-${VER}-x86_64.exe
cd ..

cd tar.gz
wget ${BASEURL}/gap-${VER}-core.tar.gz.sha256
wget ${BASEURL}/gap-${VER}-core.tar.gz
wget ${BASEURL}/gap-${VER}.tar.gz.sha256
wget ${BASEURL}/gap-${VER}.tar.gz
cd ..

cd zip
wget ${BASEURL}/gap-${VER}.zip.sha256
wget ${BASEURL}/gap-${VER}.zip
wget ${BASEURL}/gap-${VER}-core.zip.sha256
wget ${BASEURL}/gap-${VER}-core.zip
cd ..
