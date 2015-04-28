#!/usr/bin/env bash

NO_CACHE=${1:-false}

docker build --no-cache=$NO_CACHE --tag=docker.rodeopartners.com/postfix:2.11 .
docker tag -f docker.rodeopartners.com/postfix:2.11 docker.rodeopartners.com/postfix:2.11-jessie
