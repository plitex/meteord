#!/bin/bash
set -x
set -e

docker build --no-cache -t "plitex/meteord:base" ../base
docker build --no-cache -t "plitex/meteord:onbuild" ../onbuild
docker build --no-cache -t "plitex/meteord:devbuild" ../devbuild
docker build --no-cache -t "plitex/meteord:testbuild" ../testbuild
docker build --no-cache -t "plitex/meteord:binbuild" ../binbuild
