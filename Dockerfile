FROM ubuntu:bionic-20180526 AS add-apt-repositories

RUN apt-get update \
 && DEBIAN_FRONTEND=noninteractive apt-get install -y gnupg \
 && apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 14AA40EC0831756756D7F66C4F4EA0AAE5267A6C \
 && echo "deb http://ppa.launchpad.net/ondrej/php/ubuntu bionic main" >> /etc/apt/sources.list

FROM ubuntu:bionic-20180526

LABEL maintainer="sameer@damagehead.com"

ENV PHP_VERSION=7.1 \
    OWNCLOUD_VERSION=10.0.9 \
    OWNCLOUD_USER=www-data \
    OWNCLOUD_INSTALL_DIR=/var/www/owncloud \
    OWNCLOUD_DATA_DIR=/var/lib/owncloud \
    OWNCLOUD_ASSETS_DIR=/etc/docker-owncloud

ENV OWNCLOUD_BUILD_ASSETS_DIR=${OWNCLOUD_ASSETS_DIR}/build \
    OWNCLOUD_RUNTIME_ASSETS_DIR=${OWNCLOUD_ASSETS_DIR}/runtime

COPY --from=add-apt-repositories /etc/apt/trusted.gpg /etc/apt/trusted.gpg

COPY --from=add-apt-repositories /etc/apt/sources.list /etc/apt/sources.list

COPY assets/build/ ${OWNCLOUD_BUILD_ASSETS_DIR}/

RUN chmod +x ${OWNCLOUD_BUILD_ASSETS_DIR}/install.sh

RUN ${OWNCLOUD_BUILD_ASSETS_DIR}/install.sh

COPY assets/runtime/ ${OWNCLOUD_RUNTIME_ASSETS_DIR}/

COPY assets/tools/ /usr/bin/

COPY entrypoint.sh /sbin/entrypoint.sh

RUN chmod 755 /sbin/entrypoint.sh

WORKDIR ${OWNCLOUD_INSTALL_DIR}

ENTRYPOINT ["/sbin/entrypoint.sh"]

CMD ["app:owncloud"]

EXPOSE 80/tcp 9000/tcp
