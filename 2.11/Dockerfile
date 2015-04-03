FROM debian:jessie
MAINTAINER Caleb Land <caleb@land.fm>

ADD https://github.com/caleb/docker-helpers/archive/master.tar.gz /tmp/helpers.tar.gz
ADD https://github.com/caleb/syslog_forwarder/releases/download/1.0/syslog_forwarder-linux-amd64-v1.0.tar.gz /tmp/syslog_forwarder.tar.gz
ADD https://raw.githubusercontent.com/caleb/mo/master/mo /usr/local/bin/mo

# Install helpers
RUN mkdir -p /helpers \
&&  tar xzf /tmp/helpers.tar.gz -C / docker-helpers-master/helpers \
&&  mv /docker-helpers-master/helpers/* /helpers \
&&  rm -rf /docker-helpers-master \
&&  rm /tmp/helpers.tar.gz \
&&  chmod +x /usr/local/bin/mo \
&&  tar xzf /tmp/syslog_forwarder.tar.gz -C /usr/local/bin \
&&  rm /tmp/syslog_forwarder.tar.gz

RUN echo "postfix postfix/main_mailer_type string No configuration" | debconf-set-selections

# Install some dependencies
RUN apt-get update && apt-get install -y postfix postfix-pcre sasl2-bin mailutils monit runit

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
