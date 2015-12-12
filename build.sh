#!/usr/bin/env bash

NO_CACHE=${1:-false}

cd 2.11
./build.sh $NO_CACHE
cd ..
docker tag -f caleb/postfix:2.11 caleb/postfix:latest
