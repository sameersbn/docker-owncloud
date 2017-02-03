FROM sameersbn/ubuntu:14.04.20170123
MAINTAINER sameer@damagehead.com

ENV OWNCLOUD_VERSION=9.1.3 \
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
      php5-fpm php5-cli php5-gd \
      php5-pgsql php5-mysql \
      php5-curl php5-intl php5-mcrypt php5-ldap \
      php5-gmp php5-apcu php5-imagick \
      mysql-client postgresql-client nginx gettext-base \
 && sed -i 's/^listen = .*/listen = 0.0.0.0:9000/' /etc/php5/fpm/pool.d/www.conf \
 && php5enmod mcrypt \
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
