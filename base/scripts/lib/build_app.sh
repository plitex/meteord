set -e
set -x

function version_gte() {
  if [ "$1" == "$2" ]; then
    return 0 # 0==true
  else
    test "$(printf '%s\n' "$@" | sort -V | head -n 1)" != "$1";
  fi
}

COPIED_APP_PATH=/copied-app
BUNDLE_DIR=/tmp/bundle-dir

# sometimes, directly copied folder cause some wierd issues
# this fixes that
echo "=> Copying the app"
cp -R /app $COPIED_APP_PATH
cd $COPIED_APP_PATH

echo "=> Delete symlinks in packages folder"
if [ -d "packages" ]; then
  find packages -type l -delete
fi

echo "=> Executing NPM install --production"
meteor npm install --unsafe-perm --production

echo "=> Checking Meteor version"
app_meteor_version=$(meteor --version | cut -d' ' -f2)
if version_gte $app_meteor_version 1.4.2.0; then
  echo "Meteor version is >=1.4.2"
  build_type=">=1.4.2"
else
  echo "Meteor version is <1.4.2"
  build_type="<1.4.2"
fi

echo "=> Executing Meteor Build..."
#export We don't want to expose tokens
if [ "$build_type" == ">=1.4.2" ]; then
  meteor build \
    --allow-superuser \
    --directory $BUNDLE_DIR \
    --server=http://localhost:3000
elif [ "$build_type" == "<1.4.2" ]; then
  meteor build \
    --directory $BUNDLE_DIR \
    --server=http://localhost:3000
fi

echo "=> Printing Meteor Node information..."
echo "  => platform"
meteor node -p process.platform
echo "  => arch"
meteor node -p process.arch
echo "  => versions"
meteor node -p process.versions

echo "=> Printing System Node information..."
echo "  => platform"
node -p process.platform
echo "  => arch"
node -p process.arch
echo "  => versions"
node -p process.versions

echo "=> Executing NPM install within Bundle"
cd $BUNDLE_DIR/bundle/programs/server/
npm install --unsafe-perm

echo "=> Moving bundle"
mv $BUNDLE_DIR/bundle /built_app

echo "=> Cleaning up"
# cleanup
echo " => COPIED_APP_PATH"
rm -rf $COPIED_APP_PATH
echo " => BUNDLE_DIR"
rm -rf $BUNDLE_DIR
echo " => .meteor"
rm -rf ~/.meteor
rm /usr/local/bin/meteor
