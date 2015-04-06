#!/usr/bin/env bash

cd 2.11
./build.sh
cd ..
docker tag -f docker.rodeopartners.com/postfix:2.11 docker.rodeopartners.com/postfix:latest
