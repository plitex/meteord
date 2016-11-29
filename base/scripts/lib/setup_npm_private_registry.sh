#!/bin/bash
set -e

if [ -n "$NPM_PRIVATE_REGISTRY_URL" ]; then
  if [ -n "$NPM_PRIVATE_REGISTRY_SCOPE" ]; then
    echo "Setting up registry $NPM_PRIVATE_REGISTRY_URL for $NPM_PRIVATE_REGISTRY_SCOPE"
    echo "$NPM_PRIVATE_REGISTRY_SCOPE:registry=$NPM_PRIVATE_REGISTRY_URL" >> ~/.npmrc
  else
    echo "Setting up registry $NPM_PRIVATE_REGISTRY_URL"
    echo "registry=$NPM_PRIVATE_REGISTRY_URL" >> ~/.npmrc
  fi

  if [ -n "$NPM_PRIVATE_REGISTRY_TOKEN" ]; then
    echo "Adding auth token for $NPM_PRIVATE_REGISTRY_URL"
    echo "//$(echo $NPM_PRIVATE_REGISTRY_URL | awk -F/ '{print $3}')/:_authToken=\"$NPM_PRIVATE_REGISTRY_TOKEN\"" >> ~/.npmrc
  fi
else
  echo "No private registry build args found"
fi
