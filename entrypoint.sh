#!/bin/bash
set -e

OWNCLOUD_FQDN=${OWNCLOUD_FQDN:-localhost}

# create the data and conf directories
mkdir -p ${OWNCLOUD_DATA_DIR}/data
mkdir -p ${OWNCLOUD_DATA_DIR}/conf

# create symlinks
ln -sf ${OWNCLOUD_DATA_DIR}/data ${OWNCLOUD_INSTALL_DIR}/data
ln -sf ${OWNCLOUD_DATA_DIR}/conf/config.php ${OWNCLOUD_INSTALL_DIR}/config/config.php

# fix ownership of the OWNCLOUD_DATA_DIR
chown -R ${OWNCLOUD_USER}:${OWNCLOUD_USER} ${OWNCLOUD_DATA_DIR}/

# create VERSION file, not used at the moment but might be required in the future
CURRENT_VERSION=
[ -f ${OWNCLOUD_DATA_DIR}/VERSION ] && CURRENT_VERSION=$(cat ${OWNCLOUD_DATA_DIR}/VERSION)
[ "${OWNCLOUD_VERSION}" != "${CURRENT_VERSION}" ] && echo -n "${OWNCLOUD_VERSION}" > ${OWNCLOUD_DATA_DIR}/VERSION

# install nginx configuration, if not exists
if [ -d /etc/nginx/sites-enabled -a ! -f /etc/nginx/sites-enabled/${OWNCLOUD_FQDN}.conf ]; then
  cp /conf/nginx/ownCloud /etc/nginx/sites-enabled/${OWNCLOUD_FQDN}.conf
  sed -i 's/{{OWNCLOUD_FQDN}}/'"${OWNCLOUD_FQDN}"'/' /etc/nginx/sites-enabled/${OWNCLOUD_FQDN}.conf
fi

exec $@
