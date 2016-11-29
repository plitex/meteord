#!/bin/bash
set -e
set -x

function clean() {
  docker rm -f meteor-app || true
  docker rmi -f meteor-app-image || true
  rm -rf hello || true
}

cd /tmp
clean

meteor create hello
cd hello
echo "FROM plitex/meteord:devbuild" > Dockerfile

docker build -t meteor-app-image ./
docker run -d \
    --name meteor-app \
    -e ROOT_URL=http://yourapp_dot_com \
    -p 8080:80 \
    meteor-app-image

sleep 5

appContent=`curl http://localhost:8080`
clean

if [[ $appContent != *"yourapp_dot_com"* ]]; then
  echo "Failed: Meteor app"
  exit 1
fi
