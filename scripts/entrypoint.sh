#!/bin/bash

export WEBMIN_LOGIN="${WEBMIN_LOGIN:-admin}"
export WEBMIN_PASSWORD="${WEBMIN_PASSWORD:-admin}"
export USE_SSL="${USE_SSL:-true}"
export BASE_URL="${BASE_URL:-localhost}"
export ALLOW_ONLY_SAMBA_RELATED_MODULES="${ALLOW_ONLY_SAMBA_RELATED_MODULES:-true}"

if [ "${USE_SSL,,}" = true ] && [ -n "${BASE_URL+x}" ]; then
    sed -i 's/ssl=/ssl=1/g' /etc/webmin/miniserv.conf
    if [ ! -f /etc/webmin/miniserv.pem ]; then
        echo "Generating SSL certificate"
        tempdir=/tmp/certs
        mkdir -p $tempdir
        openssl req -newkey rsa:2048 -x509 -nodes -out $tempdir/cert -keyout $tempdir/key -days 1825 -sha256 -subj "/C=GB/ST=London/L=London/O=Global Security/OU=IT Department/CN=${BASE_URL}" || exit 1
        cat $tempdir/cert $tempdir/key > /etc/webmin/miniserv.pem
        rm -rf $tempdir
    fi
fi

if [ "${ALLOW_ONLY_SAMBA_RELATED_MODULES,,}" = true ]; then
    echo "admin: samba system-status backup-config changeuser webminlog webmin acl mount" >  /etc/webmin/webmin.acl
fi

if [ ! "${WEBMIN_LOGIN}" = "admin" ];then
    echo "${WEBMIN_LOGIN}:${WEBMIN_PASSWORD}" >  /etc/webmin/miniserv.users
fi

if [ ! "${WEBMIN_PASSWORD}" = "admin" ];then
    echo "Changing password for user ${WEBMIN_LOGIN}"
    /opt/webmin/changepass.pl /etc/webmin ${WEBMIN_LOGIN} ${WEBMIN_PASSWORD}
fi

if [ ! -d "/data" ]; then
  ln -s /etc/samba/* /data/samba/
  ln -s /etc/webmin/* /data/webmin
elif [ -z "$(ls -A /data)" ]; then
  cp -a /etc/samba/. /data/samba/
  cp -a /etc/webmin/. /data/webmin/
fi

/etc/webmin/stop

exec "$@"