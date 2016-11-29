#!/bin/bash
set -e
set -x

function clean() {
  docker rm -f phantomjs_check || true
}

clean
docker run  \
    --name phantomjs_check \
    --entrypoint="/bin/sh" \
    "plitex/meteord:testbuild" -c 'phantomjs -h'

sleep 5

appContent=`docker logs phantomjs_check`
clean

if [[ $appContent != *"GhostDriver"* ]]; then
  echo "Failed: Phantomjs Check"
  exit 1
fi
