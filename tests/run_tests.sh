#!/bin/bash
set -e
set -x

bash ./build_it.sh

bash ./test_meteor_app.sh
bash ./test_meteor_app_with_devbuild.sh
# I don't believe it's possible for this test to work right now.
# bash ./test_bundle_local_mount.sh

# We need to finish these tests
#bash ./test_bundle_web.sh
#bash ./test_binary_build_on_base.sh
#bash ./test_binary_build_on_bin_build.sh

bash ./test_phantomjs.sh
bash ./test_no_app.sh
