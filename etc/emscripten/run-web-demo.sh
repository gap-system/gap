#!/usr/bin/env bash

set -eux

echo This script assumes you have already run 'build.sh'

mkdir -p web-example
cp etc/emscripten/web-template/* web-example/
cp gap.js gap.wasm gap.worker.js gap-fs.json web-example/ 

cp -r pkg lib grp tst doc hpcgap dev benchmark web-example/
cd web-example
../etc/emscripten/server.rb
