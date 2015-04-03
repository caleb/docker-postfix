#!/usr/bin/env bash

docker build --tag=docker.rodeopartners.com/postfix:2.11 .
docker tag docker.rodeopartners.com/postfix:2.11 docker.rodeopartners.com/postfix:2.11-jessie
