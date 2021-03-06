#!/usr/bin/env bash

docker run -it --rm -e MYHOSTNAME=land.fm \
       --link opendkim:postfix-opendkim \
       --volumes-from rsyslog \
       caleb/postfix:3.0 /bin/bash
