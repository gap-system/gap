#!/usr/bin/env bash

set +ex
set +H

# upload to coveralls.io
if [[ -f merged-coveralls.json ]]
then
head -n 50 merged-coveralls.json
  curl -F json_file=@merged-coveralls.json "https://coveralls.io/api/v1/jobs"
fi

# upload to codecov
curl -s https://codecov.io/bash > codecov.sh
chmod +x codecov.sh
./codecov.sh -f '!./pkg/*' -f '!./extern/*' -f '!./build/*'

