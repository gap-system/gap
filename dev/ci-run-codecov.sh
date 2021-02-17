#!/usr/bin/env bash

set +ex
set +H

curl -s https://codecov.io/bash > codecov.sh
chmod +x codecov.sh
./codecov.sh -f '!./pkg/*' -f '!./extern/*' -f '!./build/*'

