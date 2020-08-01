#! /bin/bash

BRANCH=${1:-dev/7.x.x}
echo $BRANCH

IMAGE="${BRANCH/\//_}"
echo $IMAGE