#!/bin/sh
set -ex

# invoke this like so:
#  ./download_manuals.sh 4.14.0

VER=$1
[ x"$VER" != x ] || exit 1
echo "Downloading manuals for release $VER"

cd ~/data                           # follow symlink to target directory
rm -rf package-infos.json* gap-*    # delete leftovers from previous release
wget https://github.com/gap-system/gap/releases/download/v${VER}/package-infos.json.gz
gunzip package-infos.json.gz
wget https://github.com/gap-system/gap/releases/download/v${VER}/gap-${VER}.tar.gz
tar xf gap-${VER}.tar.gz
cd GapWWW
git pull
cd ..
GapWWW/etc/extract_manuals.py gap-${VER} package-infos.json
mv Manuals http/v${VER}
rm http/latest
ln -s v${VER} http/latest
