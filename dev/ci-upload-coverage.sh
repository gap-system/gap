#!/usr/bin/env bash

set +ex
set +H

# upload to coveralls.io
# TODO: perhaps fold into python script?
if [[ -f merged-coveralls.json ]]
then
  curl -F json_file=@merged-coveralls.json "https://coveralls.io/api/v1/jobs"
fi

# upload to Codecov
curl -s https://codecov.io/bash > codecov.sh
chmod +x codecov.sh
./codecov.sh -f '!./pkg/*' -f '!./extern/*' -f '!./build/*'
