#!/bin/bash

# the currend build version
BUILD_VERSION="1.0" # please change this version if you change the Dockerfile
IMAGE_NAME="py-ds-dev"

echo "Building Docker images with version [$BUILD_VERSION]"

# normal build with both tags (lastest and normal)
docker build --build-arg VERSION=normal -t $IMAGE_NAME:$BUILD_VERSION-normal -t $IMAGE_NAME:latest .

# small and large builds
docker build --build-arg VERSION=small -t $IMAGE_NAME:$BUILD_VERSION-small .
docker build --build-arg VERSION=large -t $IMAGE_NAME:$BUILD_VERSION-large .

echo "Build process completed!"