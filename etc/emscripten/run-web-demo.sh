#!/usr/bin/env bash

set -eux

echo This script assumes you have already run 'build.sh'

mkdir -p web-example/assets
cp etc/emscripten/web-template/* web-example/
cp gap.js gap.wasm gap.worker.js web-example/ 

find pkg lib grp tst doc hpcgap dev benchmark -type f | python3 etc/emscripten/copy_hashed_assets.py web-example/assets

if [ $? -ne 0 ]; then
    echo "Copying failed."
    exit 1
fi

cd web-example
../etc/emscripten/server.rb
