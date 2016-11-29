set -e

METEOR_VERSION=$METEOR_VERSION

if [ -z "$METEOR_VERSION" ] && [ -f /app/.meteor/release ]; then
  METEOR_VERSION=$(cat /app/.meteor/release | cut -d'@' -f2)
fi

if [ -z "$METEOR_VERSION" ]; then
  echo "Installing latest Meteor"
  curl -sL https://install.meteor.com | sed s/--progress-bar/-sL/g | /bin/sh
else
  echo "Installing Meteor v${METEOR_VERSION}"
  curl -sL https://install.meteor.com?release=${METEOR_VERSION} | sed s/--progress-bar/-sL/g | /bin/sh
fi
