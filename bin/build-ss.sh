#!/bin/bash

version=`cat version`

docker build -f docker/build-ss.docker -t ss-image:$version .
