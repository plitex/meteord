#!/bin/bash
set -e
set -x

: ${NODE_VERSION?"NODE_VERSION has not been set."}

function clean() {
  docker rm -f web || true
}

cd /tmp
clean

docker run -d \
    --name web \
    -e ROOT_URL=http://web_app \
    -e BUNDLE_URL=https://abernix-meteord-tests.s3-us-west-2.amazonaws.com/meteord-test-bundle.tar.gz \
    -p 9090:80 \
    "abernix/meteord:node-${NODE_VERSION}-base"

sleep 50

appContent=`curl http://localhost:9090`
clean

if [[ $appContent != *"web_app"* ]]; then
  echo "Failed: Bundle web"
  exit 1
fi
