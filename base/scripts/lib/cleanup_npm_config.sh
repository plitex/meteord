set -e
set -x

# Clean npm config
if [ -f "~/.npmrc" ]; then
  rm ~/.npmrc
fi

# Clear npm cache
npm cache clear
