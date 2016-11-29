set -e
set -x

# for npm module re-building
npm install -g node-gyp

# pre-install node source code for faster building
$(npm bin -g)/node-gyp install ${NODE_VERSION}

bash $METEORD_DIR/lib/cleanup.sh
