FROM sameersbn/php5-fpm:latest
MAINTAINER sameer@damagehead.com

ENV OWNCLOUD_VERSION 8.0.0
ENV OWNCLOUD_USER www-data
ENV OWNCLOUD_INSTALL_DIR /var/www/owncloud
ENV OWNCLOUD_DATA_DIR /data

COPY install.sh /install.sh
RUN chmod 755 /install.sh
RUN /install.sh

COPY conf /conf

COPY entrypoint.sh /entrypoint.sh
RUN chmod 755 /entrypoint.sh

VOLUME ["${OWNCLOUD_INSTALL_DIR}"]
VOLUME ["${OWNCLOUD_DATA_DIR}"]

ENTRYPOINT ["/entrypoint.sh"]
CMD ["echo", "Data-only container with ownCloud application source"]
