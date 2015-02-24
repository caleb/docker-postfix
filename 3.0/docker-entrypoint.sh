#!/bin/bash
set -e
shopt -s globstar nullglob

. /helpers/rsyslog.sh
link_rsyslog

# Set up some default variables
: ${MYORIGIN:='$mydomain'}
: ${MYDESTINATION:='$myhostname, localhost.$mydomain, localhost'}

# If the hostname is specified and the domain isn't specified, make sure the hostname isn't
# set to a second level domain (i.e. a hostname "land.fm" would result in a domain of "fm")
if [ -n "${MYHOSTNAME}" ] && [ -z "${MYDOMAIN}" ]; then
  if [[ "${MYHOSTNAME}" =~ ^[^.]+\.([^.]+)$ ]]; then
    cat >&2 <<EOF
Setting mydomain to \$myhostname because \$myhostname contains only two components
(${MYHOSTNAME}) which would result in a default mydomain of "${BASH_REMATCH[1]}".
EOF
    export MYDOMAIN='$myhostname'
  fi
fi

# Append the main.cf template onto the end of main.f
/usr/local/bin/mo /etc/postfix/main.cf.mo >> /etc/postfix/main.cf
rm /etc/postfix/main.cf.mo

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
