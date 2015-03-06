#!/usr/bin/env bash

docker run -it --rm -e MYHOSTNAME=land.fm \
       --volumes-from rsyslog \
       docker.rodeopartners.com/postfix:3.0 /bin/bash
