FROM debian:jessie
MAINTAINER Caleb Land <caleb@land.fm>

## Install Postfix.
ENV POSTFIX_VERSION=3.0.0
ENV CYRUS_SASL_VERSION=2.1.26
ADD postfix-${POSTFIX_VERSION}.tar.gz /
ADD cyrus-sasl-${CYRUS_SASL_VERSION}.tar.gz /

RUN apt-get update
RUN apt-get install -y build-essential libdb-dev
RUN apt-get install -y libssl-dev libpcre3-dev

RUN useradd --system --no-create-home --no-user-group -g sasl sasl \
&&  useradd --system --no-create-home --groups sasl postfix

RUN cd /cyrus-sasl-${CYRUS_SASL_VERSION} \
&&  ./configure --prefix=/usr --sysconfdir=/etc --without-saslauthd \
&&  make && make install

# Run saslpasswd -d (which usually deletes a user) to create the /etc/sasldb2 database
RUN saslpasswd2 -d dummy \
&&  chown sasl:sasl /etc/sasldb2 \
&&  chmod 660 /etc/sasldb2 \
&&  mkdir -p /etc/sasl2

RUN cd /postfix-${POSTFIX_VERSION} \
&&  make makefiles dynamicmaps=yes CCARGS="-DUSE_TLS -DHAS_PCRE $(pcre-config --cflags)" AUXLIBS="-lssl -lcrypto" AUXLIBS_PCRE="$(pcre-config --libs)" \
&&  make && ./postfix-install -non-interactive

# RUN rm -rf /var/lib/apt/lists/*

# pre config
# RUN echo mail > /etc/hostname
# RUN echo "postfix postfix/main_mailer_type string Internet site" > preseed.txt
# RUN echo "postfix postfix/mailname string mail.example.com" >> preseed.txt

# load pre config for apt
# RUN debconf-set-selections preseed.txt

# install
# RUN apt-get update && apt-get install -y \
#     postfix \
#     opendkim \
#     mailutils \
#     opendkim-tools \
#     sasl2-bin

## Configure Postfix

# RUN postconf -e smtpd_banner="\$myhostname ESMTP"
# RUN postconf -e mail_spool_directory="/var/spool/mail/"
# RUN postconf -e mailbox_command=""

## Configure Sasl2

# config
# RUN sed -i 's/^START=.*/START=yes/g' /etc/default/saslauthd
# RUN sed -i 's/^MECHANISMS=.*/MECHANISMS="shadow"/g' /etc/default/saslauthd

# RUN echo "pwcheck_method: saslauthd" > /etc/postfix/sasl/smtpd.conf
# RUN echo "mech_list: PLAIN LOGIN" >> /etc/postfix/sasl/smtpd.conf
# RUN echo "saslauthd_path: /var/run/saslauthd/mux" >> /etc/postfix/sasl/smtpd.conf

# postfix settings
# RUN postconf -e smtpd_sasl_auth_enable="yes"
# RUN postconf -e smtpd_recipient_restrictions="permit_mynetworks permit_sasl_authenticated reject_unauth_destination"
# RUN postconf -e smtpd_helo_restrictions="permit_sasl_authenticated, permit_mynetworks, reject_invalid_hostname, reject_unauth_pipelining, reject_non_fqdn_hostname"

# add user postfix to sasl group
# RUN adduser postfix sasl

# chroot saslauthd fix
# RUN sed -i 's/^OPTIONS=/#OPTIONS=/g' /etc/default/saslauthd
# RUN echo 'OPTIONS="-c -m /var/spool/postfix/var/run/saslauthd"' >> /etc/default/saslauthd

# dkim settings
# RUN mkdir -p /etc/postfix/dkim
# RUN echo "KeyFile                 /etc/postfix/dkim/dkim.key" >> /etc/opendkim.conf
# RUN echo "Selector                mail" >> /etc/opendkim.conf
# RUN echo "SOCKET                  inet:8891@localhost" >> /etc/opendkim.conf

# RUN sed -i 's/^SOCKET=/#SOCKET=/g' /etc/default/opendkim
# RUN echo 'SOCKET="inet:8891@localhost"' >> /etc/default/opendkim

## FINISHED

# Postfix Ports
EXPOSE 25

# Add startup script
ADD docker-entrypoint.sh /entrypoint.sh

# Docker startup
ENTRYPOINT ["/entrypoint.sh"]
CMD ["-h"]
