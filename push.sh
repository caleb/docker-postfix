#!/usr/bin/env bash

cd 2.11
./push.sh
cd ..
docker push docker.rodeopartners.com/postfix:latest
