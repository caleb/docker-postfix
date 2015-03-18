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
export MAIN_SMTPD_HELO_RESTRICTIONS
export MAIN_SMTPD_RECIPIENT_RESTRICTIONS
export MAIN_SMTPD_SASL_AUTH_ENABLE

# Ensure the domain or hostname is set
if [ -z "${MAIN_MYDOMAIN}" ] && [ -z "${MAIN_MYHOSTNAME}" ]; then
  echo "You must set either the MAIN_MYDOMAIN or MAIN_MYHOSTNAME variables" >&2
  exit 1
fi

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
    export MAIN_MYDOMAIN="${MAIN_MYHOSTNAME}"
  else
    domain="$(echo "${MAIN_MYHOSTNAME}" | cut -d '.' -f 1 --complement)"
    export MAIN_MYDOMAIN="${domain}"
  fi
elif [ -z "${MAIN_MYHOSTNAME}" ] && [ -n "${MAIN_MYDOMAIN}" ]; then
  # if the domain is set but not the hostname, set the hostname to the domain name
  export MAIN_MYHOSTNAME="${MAIN_MYDOMAIN}"
fi

#
# If opendkim is linked, set that up
#
if [ -n "${OPENDKIM_ADDR}" ] && [ -n "${OPENDKIM_PORT}" ]; then
  export MAIN_MILTER_DEFAULT_ACTION=accept
  export MAIN_MILTER_PROTOCOL=2
  export MAIN_SMTPD_MILTERS=inet:${OPENDKIM_ADDR}:${OPENDKIM_PORT}
  export MAIN_NON_SMTPD_MILTERS=inet:${OPENDKIM_ADDR}:${OPENDKIM_PORT}
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

#
# Add users
#
if [ -n "${USER}" ]; then
  export USER__DEFAULT__="${USER}"
fi

for var in ${!USER_*}; do
  if [[ "${!var}" =~ ^([^:]+):(.*)$ ]]; then
    username="${BASH_REMATCH[1]}"
    password="${BASH_REMATCH[2]}"
    echo "Creating user \"${username}\" with password \"${password}\""
    echo "${password}" | saslpasswd2 -p -c -u "${MAIN_MYDOMAIN}" "${username}"
  else
    echo "Misformed user variable ${var}=${!var}. Should be ${var}=username:password" >&2
    exit 1
  fi
done

exec "${@}"
