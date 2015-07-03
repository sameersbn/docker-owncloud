FROM sameersbn/php5-fpm:latest
MAINTAINER sameer@damagehead.com

ENV OWNCLOUD_VERSION=8.0.0 \
    OWNCLOUD_USER=${PHP_FPM_USER} \
    OWNCLOUD_INSTALL_DIR=/var/www/owncloud \
    OWNCLOUD_DATA_DIR=/var/lib/owncloud

ENV OWNCLOUD_CONF_DIR=${OWNCLOUD_DATA_DIR}/conf \
    OWNCLOUD_OCDATA_DIR=${OWNCLOUD_DATA_DIR}/ocdata

RUN apt-get update \
 && apt-get install -y php5-pgsql php5-mysql php5-gd php-file \
      php5-curl php5-intl php5-mcrypt php5-ldap \
      php-net-ftp php5-gmp php5-apcu php5-imagick \
 && php5enmod mcrypt \
 && rm -rf /var/lib/apt/lists/*

COPY install.sh /var/cache/owncloud/install.sh
RUN bash /var/cache/owncloud/install.sh

COPY conf/ /var/cache/owncloud/conf/
COPY entrypoint.sh /sbin/entrypoint.sh
RUN chmod 755 /sbin/entrypoint.sh

VOLUME ["${OWNCLOUD_INSTALL_DIR}", "${OWNCLOUD_DATA_DIR}"]

WORKDIR ${OWNCLOUD_INSTALL_DIR}
ENTRYPOINT ["/sbin/entrypoint.sh"]
CMD ["/usr/sbin/php5-fpm"]
