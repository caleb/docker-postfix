FROM debian:jessie
MAINTAINER Caleb Land <caleb@land.fm>

ADD https://github.com/caleb/docker-helpers/archive/master.tar.gz /tmp/helpers.tar.gz
ADD https://raw.githubusercontent.com/caleb/mo/master/mo /usr/local/bin/mo

# Install helpers
RUN mkdir -p /helpers \
&&  tar xzf /tmp/helpers.tar.gz -C / docker-helpers-master/helpers \
&&  mv /docker-helpers-master/helpers/* /helpers \
&&  rm -rf /docker-helpers-master \
&&  rm /tmp/helpers.tar.gz \
&&  chmod +x /usr/local/bin/mo

RUN echo "postfix postfix/main_mailer_type string No configuration" | debconf-set-selections

# Install some dependencies
RUN apt-get update && apt-get install -y postfix postfix-pcre sasl2-bin mailutils

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
#CMD ["/usr/libexec/postfix/master"]
