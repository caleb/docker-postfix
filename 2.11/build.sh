#!/usr/bin/env bash

NO_CACHE=${1:-false}

docker build --no-cache=$NO_CACHE --tag=caleb/postfix:2.11 .
docker tag -f caleb/postfix:2.11 caleb/postfix:2.11-jessie
