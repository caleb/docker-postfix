FROM debian:jessie
MAINTAINER Caleb Land <caleb@land.fm>

ENV DOCKER_HELPERS_VERSION=1.0

# Download our docker helpers
ADD https://github.com/caleb/docker-helpers/releases/download/v${DOCKER_HELPERS_VERSION}/helpers-v${DOCKER_HELPERS_VERSION}.tar.gz /tmp/helpers.tar.gz

# Install the docker helpers
RUN mkdir -p /helpers \
&&  tar xzf /tmp/helpers.tar.gz -C / \
&&  rm /tmp/helpers.tar.gz

# Install the base system
RUN /bin/bash /helpers/install-base.sh

RUN echo "postfix postfix/main_mailer_type string No configuration" | debconf-set-selections

# Install some software
RUN apt-get update \
&&  apt-get install -y postfix postfix-pcre sasl2-bin mailutils \
&&  rm -rf /var/lib/apt/lists/*

# Run postfix non-chrooted
ADD master.cf /etc/postfix/master.cf
RUN chmod go-wx /etc/postfix/master.cf

# Add the Monit configuration
ADD monit/monitrc /etc/monitrc

# Add the runit configuration
ADD sv /etc/service

# Add the sasl configuration for smtpd
ADD smtpd.conf /etc/postfix/sasl/smtpd.conf

# Add user postfix to sasl group
RUN adduser postfix sasl

# Postfix Ports
EXPOSE 25

# Add startup script
ADD docker-entrypoint.sh /entrypoint.sh

# Docker startup
ENTRYPOINT ["/entrypoint.sh"]
CMD ["postfix"]
