FROM sameersbn/php5-fpm:latest
MAINTAINER sameer@damagehead.com

ENV OWNCLOUD_VERSION=9.1.1 \
    OWNCLOUD_USER=${PHP_FPM_USER} \
    OWNCLOUD_INSTALL_DIR=/var/www/owncloud \
    OWNCLOUD_DATA_DIR=/var/lib/owncloud \
    OWNCLOUD_CACHE_DIR=/etc/docker-owncloud

ENV OWNCLOUD_BUILD_DIR=${OWNCLOUD_CACHE_DIR}/build \
    OWNCLOUD_RUNTIME_DIR=${OWNCLOUD_CACHE_DIR}/runtime

RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 8B3981E7A6852F782CC4951600A6F0A3C300EE8C \
 && echo "deb http://ppa.launchpad.net/nginx/stable/ubuntu trusty main" >> /etc/apt/sources.list \
 && wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add - \
 && echo 'deb http://apt.postgresql.org/pub/repos/apt/ trusty-pgdg main' > /etc/apt/sources.list.d/pgdg.list \
 && apt-get update \
 && DEBIAN_FRONTEND=noninteractive apt-get install -y \
      php5-pgsql php5-mysql php5-gd php-file \
      php5-curl php5-intl php5-mcrypt php5-ldap \
      php-net-ftp php5-gmp php5-apcu php5-imagick \
      mysql-client postgresql-client nginx gettext-base \
 && php5enmod mcrypt \
 && rm -rf /var/lib/apt/lists/*

COPY assets/build/ ${OWNCLOUD_BUILD_DIR}/
RUN bash ${OWNCLOUD_BUILD_DIR}/install.sh

COPY assets/runtime/ ${OWNCLOUD_RUNTIME_DIR}/
COPY assets/tools/ /usr/bin/
COPY entrypoint.sh /sbin/entrypoint.sh
RUN chmod 755 /sbin/entrypoint.sh

EXPOSE 80/tcp

VOLUME ["${OWNCLOUD_DATA_DIR}"]

WORKDIR ${OWNCLOUD_INSTALL_DIR}
ENTRYPOINT ["/sbin/entrypoint.sh"]
CMD ["app:owncloud"]
