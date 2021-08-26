#!/bin/bash
# See https://blog.tomecek.net/post/kerberos-in-a-container

set -e

# Generate passwd file based on current uid / OCP fix
USER_ID=$(id -u)
GROUP_ID=$(id -g)
PASSWD_FILE="/tmp/.passwd"

grep -v -e ^default -e "^$USER_ID" /etc/passwd > $PASSWD_FILE
echo "default:x:${USER_ID}:${GROUP_ID}:Default Application User:${HOME}:/sbin/nologin" >> $PASSWD_FILE
cat $PASSWD_FILE > /etc/passwd


REFRESH_SECONDS=${REFRESH_SECONDS:-28800}
#DEFAULT_KRB5_CONFIG="/etc/krb5.conf"

# Set Default Configuration Values
#export KRB5_CONFIG=${KRB5_CONFIG:-$DEFAULT_KRB5_CONFIG}
#export KRB5_KTNAME=${KRB5_KTNAME:-/krb5/sa.keytab}
#export KRB5_CLIENT_KTNAME=${KRB5_CLIENT_KTNAME:-/tmp/sa.keytab}
#export KRB5CCNAME=${KRB5CCNAME:-FILE:/tmp/krb.cache}

KRB5_SA_USERNAME=${KRB5_SA_USERNAME:-default}
KRB5_SA_PASSWORD=${KRB5_SA_PASSWORD:-password}

# intialize krb token
kinit "${KRB5_SA_USERNAME}" -V < <(echo -e "${KRB5_SA_PASSWORD}\n")

# auto refresh token
while true
do
  echo "*** kinit at $(date -u)"
  kinit -R -V "${KRB5_SA_USERNAME}" || kinit "${KRB5_SA_USERNAME}" -V < <(echo -e "${KRB5_SA_PASSWORD}\n")
  klist -A -e -f -d

  if [ -z "${SKIP_REFRESH}" ] || [ "${SKIP_REFRESH}" != "true" ]; then
    echo "*** Waiting for $REFRESH_SECONDS seconds"
    sleep "$REFRESH_SECONDS"
  else
    break
  fi
done
