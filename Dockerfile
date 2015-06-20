FROM sameersbn/php5-fpm:latest
MAINTAINER sameer@damagehead.com

ENV OWNCLOUD_VERSION=8.0.0 \
    OWNCLOUD_USER=${PHP_FPM_USER} \
    OWNCLOUD_INSTALL_DIR=/var/www/owncloud \
    OWNCLOUD_DATA_DIR=/data

RUN apt-get update \
 && apt-get install -y php5-pgsql php5-mysql php5-gd php-file \
      php5-curl php5-intl php5-mcrypt php5-ldap \
      php-net-ftp php5-gmp php5-apcu php5-imagick \
 && rm -rf /var/lib/apt/lists/*

COPY install.sh /install.sh
RUN chmod 755 /install.sh
RUN /install.sh

COPY conf /conf

COPY entrypoint.sh /entrypoint.sh
RUN chmod 755 /entrypoint.sh

VOLUME ["${OWNCLOUD_INSTALL_DIR}", "${OWNCLOUD_DATA_DIR}"]

WORKDIR ${OWNCLOUD_INSTALL_DIR}
ENTRYPOINT ["/entrypoint.sh"]
CMD ["/usr/sbin/php5-fpm"]
