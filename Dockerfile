FROM sameersbn/ubuntu:14.04.20170123
MAINTAINER sameer@damagehead.com

ENV PHP_VERSION=7.0 \
    OWNCLOUD_VERSION=9.1.4 \
    OWNCLOUD_USER=www-data \
    OWNCLOUD_INSTALL_DIR=/var/www/owncloud \
    OWNCLOUD_DATA_DIR=/var/lib/owncloud \
    OWNCLOUD_CACHE_DIR=/etc/docker-owncloud

ENV OWNCLOUD_BUILD_DIR=${OWNCLOUD_CACHE_DIR}/build \
    OWNCLOUD_RUNTIME_DIR=${OWNCLOUD_CACHE_DIR}/runtime

RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 14AA40EC0831756756D7F66C4F4EA0AAE5267A6C \
 && echo "deb http://ppa.launchpad.net/ondrej/php/ubuntu trusty main" >> /etc/apt/sources.list \
 && apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 8B3981E7A6852F782CC4951600A6F0A3C300EE8C \
 && echo "deb http://ppa.launchpad.net/nginx/stable/ubuntu trusty main" >> /etc/apt/sources.list \
 && wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add - \
 && echo 'deb http://apt.postgresql.org/pub/repos/apt/ trusty-pgdg main' > /etc/apt/sources.list.d/pgdg.list \
 && apt-get update \
 && DEBIAN_FRONTEND=noninteractive apt-get install -y \
      nginx mysql-client postgresql-client gettext-base \
      php${PHP_VERSION}-fpm php${PHP_VERSION}-cli php${PHP_VERSION}-gd \
      php${PHP_VERSION}-pgsql php${PHP_VERSION}-mysql php${PHP_VERSION}-curl \
      php${PHP_VERSION}-zip php${PHP_VERSION}-xml php${PHP_VERSION}-mbstring \
      php${PHP_VERSION}-intl php${PHP_VERSION}-mcrypt php${PHP_VERSION}-ldap \
      php${PHP_VERSION}-gmp php${PHP_VERSION}-apcu php${PHP_VERSION}-imagick \
 && sed -i 's/^listen = .*/listen = 0.0.0.0:9000/' /etc/php/${PHP_VERSION}/fpm/pool.d/www.conf \
 && phpenmod -v ALL mcrypt \
 && rm -rf /var/lib/apt/lists/*

COPY assets/build/ ${OWNCLOUD_BUILD_DIR}/
RUN bash ${OWNCLOUD_BUILD_DIR}/install.sh

COPY assets/runtime/ ${OWNCLOUD_RUNTIME_DIR}/
COPY assets/tools/ /usr/bin/
COPY entrypoint.sh /sbin/entrypoint.sh
RUN chmod 755 /sbin/entrypoint.sh

VOLUME ["${OWNCLOUD_DATA_DIR}"]
WORKDIR ${OWNCLOUD_INSTALL_DIR}
ENTRYPOINT ["/sbin/entrypoint.sh"]
CMD ["app:owncloud"]

EXPOSE 80/tcp 9000/tcp
