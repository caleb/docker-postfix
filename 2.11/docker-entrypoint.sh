#!/bin/bash
set -e
shopt -s globstar nullglob

. /helpers/rsyslog.sh
link_rsyslog

. /helpers/links.sh
read_link OPENDKIM opendkim 8891 tcp

export MAIN_MYORIGIN
export MAIN_MYDESTINATION
export MAIN_UNKNOWN_LOCAL_RECIPIENT_REJECT_CODE
export MAIN_MYNETWORKS
export MAIN_SMTPD_BANNER
export MAIN_DEBUGGER_COMMAND
export MAIN_INET_PROTOCOLS

# Set up some default variables
: ${MAIN_MYORIGIN:='$mydomain'}
: ${MAIN_MYDESTINATION:='$myhostname, localhost.$mydomain, localhost'}
: ${MAIN_UNKNOWN_LOCAL_RECIPIENT_REJECT_CODE:='550'}
: ${MAIN_MYNETWORKS:='127.0.0.0/8'}
: ${MAIN_SMTPD_BANNER:='$myhostname ESMTP $mail_name (Debian/GNU)'}
: ${MAIN_DEBUGGER_COMMAND:='PATH=/bin:/usr/bin:/usr/local/bin ddd $daemon_directory/$process_name $process_id & sleep 5'}
: ${MAIN_INET_PROTOCOLS:='ipv4'}
: ${MAIN_SMTPD_SASL_AUTH_ENABLE:='yes'}
: ${MAIN_SMTPD_RECIPIENT_RESTRICTIONS:='permit_mynetworks permit_sasl_authenticated reject_unauth_destination'}
: ${MAIN_SMTPD_HELO_RESTRICTIONS:='permit_sasl_authenticated, permit_mynetworks, reject_invalid_hostname, reject_unauth_pipelining, reject_non_fqdn_hostname'}

# If the hostname is specified and the domain isn't specified, make sure the hostname isn't
# set to a second level domain (i.e. a hostname "land.fm" would result in a domain of "fm")
if [ -n "${MAIN_MYHOSTNAME}" ] && [ -z "${MAIN_MYDOMAIN}" ]; then
  if [[ "${MAIN_MYHOSTNAME}" =~ ^[^.]+\.([^.]+)$ ]]; then
    cat >&2 <<EOF
Setting mydomain to \$myhostname because \$myhostname contains only two components
(${MYHOSTNAME}) which would result in a default mydomain of "${BASH_REMATCH[1]}".
EOF
    MAIN_MYDOMAIN='$myhostname'
  fi
fi

if [ ! -f /etc/postfix/main.cf ]; then
  for var in ${!MAIN_*}; do
    var_minus_prefix="${var#MAIN_}"
    var_downcased="${var_minus_prefix,,}"
    echo "${var_downcased} = ${!var}" >> /etc/postfix/main.cf
  done
fi

for template in /etc/postfix/**/*.mo; do
  /usr/local/bin/mo "${template}" > "${template%.mo}"
  rm "${template}"
done


# # add domain
# postconf -e myhostname="$1"
# postconf -e mydestination="$1"
# echo "$1" > /etc/mailname
# echo "Domain $1" >> /etc/opendkim.conf

# if [ ${#@} -gt 1 ]
# then
#   echo ">> adding users..."

#   # all arguments but skip first argumenti
#   i=0
#   for ARG in "$@"
#   do
#     if [ $i -gt 0 ] && [ "$ARG" != "${ARG/://}" ]
#     then
#       USER=`echo "$ARG" | cut -d":" -f1`
#       echo "    >> adding user: $USER"
#       useradd -s /bin/bash $USER
#       echo "$ARG" | chpasswd
#       if [ ! -d /var/spool/mail/$USER ]
#       then
#         mkdir /var/spool/mail/$USER
#       fi
#       chown -R $USER:mail /var/spool/mail/$USER
#       chmod -R a=rwx /var/spool/mail/$USER
#       chmod -R o=- /var/spool/mail/$USER
#     fi

#     i=`expr $i + 1`
#   done
# fi

# # DKIM
# if [ -z ${DISABLE_DKIM+x} ]
# then
#   echo ">> enable DKIM support"

#   if [ -z ${DKIM_CANONICALIZATION+x} ]
#   then
#     DKIM_CANONICALIZATION="simple"
#   fi

#   echo "Canonicalization $DKIM_CANONICALIZATION" >> /etc/opendkim.conf

#   postconf -e milter_default_action="accept"
#   postconf -e milter_protocol="2"
#   postconf -e smtpd_milters="inet:localhost:8891"
#   postconf -e non_smtpd_milters="inet:localhost:8891"

#   # add dkim if necessary
#   if [ ! -f /etc/postfix/dkim/dkim.key ]
#   then
#     echo ">> no dkim.key found - generate one..."
#     opendkim-genkey -s mail -d $1
#     mv mail.private /etc/postfix/dkim/dkim.key
#     echo ">> printing out public dkim key:"
#     cat mail.txt
#     mv mail.txt /etc/postfix/dkim/dkim.public
#     echo ">> please at this key to your DNS System"
#   fi
#   echo ">> change user and group of /etc/postfix/dkim/dkim.key to opendkim"
#   chown opendkim:opendkim /etc/postfix/dkim/dkim.key
#   chmod o=- /etc/postfix/dkim/dkim.key
# fi

# # add aliases
# > /etc/aliases
# if [ ! -z ${ALIASES+x} ]
# then
#   IFS=';' read -ra ADDR <<< "$ALIASES"
#   for i in "${ADDR[@]}"; do
#     echo "$i" >> /etc/aliases
#     echo ">> adding $i to /etc/aliases"
#   done
# fi
# echo ">> the new /etc/aliases file:"
# cat /etc/aliases
# newaliases

# # starting services
# echo ">> starting the services"
# service rsyslog start

# if [ -z ${DISABLE_DKIM+x} ]
# then
#   service opendkim start
# fi

# service saslauthd start
# service postfix start

# # print logs
# echo ">> printing the logs"
# touch /var/log/mail.log /var/log/mail.err /var/log/mail.warn
# chmod a+rw /var/log/mail.*
# tail -F /var/log/mail.*

exec "${@}"
