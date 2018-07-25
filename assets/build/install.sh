#!/bin/bash
set -e

mkdir -p ${OWNCLOUD_INSTALL_DIR}

if [[ ! -f ${OWNCLOUD_BUILD_DIR}/owncloud-${OWNCLOUD_VERSION}.tar.bz2 ]]; then
  echo "Downloading ownCloud ${OWNCLOUD_VERSION}..."
  wget "https://download.owncloud.org/community/owncloud-${OWNCLOUD_VERSION}.tar.bz2" -O ${OWNCLOUD_BUILD_DIR}/owncloud-${OWNCLOUD_VERSION}.tar.bz2
fi

echo "Extracting ownCloud ${OWNCLOUD_VERSION}..."
tar -xf ${OWNCLOUD_BUILD_DIR}/owncloud-${OWNCLOUD_VERSION}.tar.bz2 --strip=1 -C ${OWNCLOUD_INSTALL_DIR}
rm -rf ${OWNCLOUD_BUILD_DIR}/owncloud-${OWNCLOUD_VERSION}.tar.bz2

# required by owncloud
sed -i "s|[;]*[ ]*always_populate_raw_post_data = .*|always_populate_raw_post_data = -1|" /etc/php/${PHP_VERSION}/fpm/php.ini
sed -i "s|[;]*[ ]*always_populate_raw_post_data = .*|always_populate_raw_post_data = -1|" /etc/php/${PHP_VERSION}/cli/php.ini

mkdir -p /run/php/

# remove default nginx virtualhost
rm -rf /etc/nginx/sites-enabled/default

# set directory permissions
find ${OWNCLOUD_INSTALL_DIR}/ -type f -print0 | xargs -0 chmod 0640
find ${OWNCLOUD_INSTALL_DIR}/ -type d -print0 | xargs -0 chmod 0750
chown -R root:${OWNCLOUD_USER} ${OWNCLOUD_INSTALL_DIR}/
chown -R ${OWNCLOUD_USER}: ${OWNCLOUD_INSTALL_DIR}/apps/
chown -R ${OWNCLOUD_USER}: ${OWNCLOUD_INSTALL_DIR}/config/
chown root:${OWNCLOUD_USER} ${OWNCLOUD_INSTALL_DIR}/.htaccess
chmod 0644 ${OWNCLOUD_INSTALL_DIR}/.htaccess
chown root:${OWNCLOUD_USER} ${OWNCLOUD_INSTALL_DIR}/.user.ini
chmod 0644 ${OWNCLOUD_INSTALL_DIR}/.user.ini
