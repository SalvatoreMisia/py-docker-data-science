#!/bin/bash

# the currend build version
BUILD_VERSION="1.0" # please change this version if you change the Dockerfile

# normal build with both tags (lastest and normal)
docker build --build-arg VERSION=normal -t py-ds:$BUILD_VERSION-normal -t py-ds:latest .

# small and large builds
docker build --build-arg VERSION=small -t py-ds:$BUILD_VERSION-small .
docker build --build-arg VERSION=large -t py-ds:$BUILD_VERSION-large .