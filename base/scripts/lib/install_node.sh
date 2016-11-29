#!/bin/bash
set -e

NODE_ARCH=x64

if [ -n "$NODE_VERSION" ]; then
  echo "Using Node version from args"
  NODE_VERSION=v${NODE_VERSION}
elif [ -f /usr/local/bin/meteor ]; then
  echo "Using Node version from Meteor release"
  NODE_VERSION=$(meteor node -v)
else
  echo "Must set NODE_VERSION with --build-arg NODE_VERSION=x.y.z when building docker image"
  exit 1
fi

NODE_DIST=node-${NODE_VERSION}-linux-${NODE_ARCH}

echo "Installing Node ${NODE_VERSION}"

cd /tmp
curl -O -L http://nodejs.org/dist/${NODE_VERSION}/${NODE_DIST}.tar.gz
tar xzf ${NODE_DIST}.tar.gz
rm -rf /opt/nodejs
mv ${NODE_DIST} /opt/nodejs
rm ${NODE_DIST}.tar.gz

ln -sf /opt/nodejs/bin/node /usr/bin/node
ln -sf /opt/nodejs/bin/npm /usr/bin/npm

npm install --global npm@3
