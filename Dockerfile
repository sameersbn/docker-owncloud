FROM sameersbn/php5-fpm:latest
MAINTAINER sameer@damagehead.com

ENV OWNCLOUD_VERSION=8.0.0 \
    OWNCLOUD_USER=www-data \
    OWNCLOUD_INSTALL_DIR=/var/www/owncloud \
    OWNCLOUD_DATA_DIR=/data

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
