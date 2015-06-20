
**EXPERIMENTAL: Please do not use in production**

- [Introduction](#introduction)
- [Dedicated php-fpm workers](#dedicated-php-fpm-workers)
- [Shared php-fpm workers](#shared-php-fpm-workers)
- [Final Steps](#final-steps)

# Introduction

This is an experimental image intended for learning/demonstration of docker volumes. This is more of a proof of concept image and not intended to be used in production at this time.

Before we get into the nitty-gritties, lets take care of a few questions you may have.

*Does it work?*

Yes

*Can I use it in production?*

Not at this time. Only use it if you want to provide feedback or if you want to contribute or understand how all of this works together and then maybe use this information while building your own containers.

Since this is a study exercise at the moment the image will change significantly over a period of time.

*What does not work?*

- You *cannot* install external plugins
- SSL support is not enabled, you need to do it manually and on your own
- File upload size is limited to `2G`

You can launch this image in two ways
  - Dedicated php-fpm workers
  - Shared php-fpm workers

# Dedicated php-fpm workers

In this mode, we start php-fpm workers specifically for owncloud. These cannot be shared for use with by other php applications.

Now lets get started. We start by creating data-only containers to isolate data from the various containers as much as we can so that we only expose as much as we need to.

```bash
# create data-only container for nginx sites configuration
docker run -d --name=nginxSites \
  --volume /srv/docker/owncloud/nginx/sites-enabled:/etc/nginx/sites-enabled \
  busybox:latest \
  echo "Data-only container for nginx sites configuration"
```

Will create a data-only container for nginx site configurations. The owncloud container will automatically install a vhost configuration for accessing owncloud at this volume.

```bash
# create postgresql container
docker run -d --name=postgresql \
  --env 'DB_USER=owncloud' \
  --env 'DB_PASS=password' --env 'DB_NAME=owncloud_db' \
  --volume /srv/docker/owncloud/postgresql:/var/lib/postgresql \
  sameersbn/postgresql:latest
```

Will create a postgresql container and a user and schema for the owncloud installation. This container can be used as a regular postgresql server for other applications if desired. It is not tied owncloud.

```bash
# create data-only container with ownCloud source
docker run -d --name=owncloud \
  --env OWNCLOUD_FQDN=cloud.example.com \
  --link postgresql:postgresql \
  --volume /srv/docker/owncloud/owncloud:/var/lib/owncloud \
  --volumes-from nginxSites \
  sameersbn/owncloud:latest
```

Will create the owncloud container exposing the owncloud source. The container will also install a virtual host configuration for nginx via the `nginxSites` volume import. The `OWNCLOUD_FQDN` variable is used to configure the `server_name` variable in the virtual host configuration. If a configuration with the name `ownCloud` already exists it will not be overwritten. Owncloud data will be stored in the volume mounted at `/var/lib/owncloud`.

```bash
# create nginx container
docker run -d --name=nginx \
  --publish 80:80 \
  --link owncloud:php-fpm \
  --volumes-from nginxSites \
  --volumes-from owncloud \
  sameersbn/nginx:latest
```

Will create a `nginx` container and listen on host port `80`. If port `80` is already in use, then you can change the host port in the above command. The owncloud virtual host configuration will already be available in the `nginxSites` volume as it will be installed by the `owncloud` container in the previous commands. The `owncloud` volume import will make the owncloud source available to the nginx container, thereby allowing it to handle requests to static site assets. This `nginx` container can be used for hosting other applications or act as a load balancer and can be treated as a generic `nginx` container just like the `postgresql` container.

All of the above setup can be achived using `docker-compose-dedicated-workers.yml` file present in this repository. Make sure you update the `OWNCLOUD_FQDN` in the `docker-compose-dedicated-workers.yml` file before starting it up

The `postgresql`, and `nginx` containers are not specific to the owncloud installation and can be re-used with other applications as well.

# Shared php-fpm workers

In this mode, we start a separate php-fpm container that is not specific to use by the owncloud container. This php-fpm container can be shared use with by other php applications as well.

We start by creating data-only containers to isolate data from the various containers as much as we can so that we only expose as much as we need to.

```bash
# create data-only container for nginx sites configuration
docker run -d --name=nginxSites \
  --volume /srv/docker/owncloud/nginx/sites-enabled:/etc/nginx/sites-enabled \
  busybox:latest \
  echo "Data-only container for nginx sites configuration"
```

Will create a data-only container for nginx site configurations. The owncloud container will automatically install a vhost configuration for accessing owncloud at this volume.

```bash
# create postgresql container
docker run -d --name=postgresql \
  --env 'DB_USER=owncloud' \
  --env 'DB_PASS=password' --env 'DB_NAME=owncloud_db' \
  --volume /srv/docker/owncloud/postgresql:/var/lib/postgresql \
  sameersbn/postgresql:latest
```

Will create a postgresql container and a user and schema for the owncloud installation. This container can be used as a regular postgresql server for other applications if desired. It is not tied owncloud.

```bash
# create data-only container with ownCloud source
docker run -d --name=owncloud \
  --env OWNCLOUD_FQDN=cloud.example.com \
  --link postgresql:postgresql \
  --volume /srv/docker/owncloud/owncloud:/var/lib/owncloud
  --volumes-from nginxSites \
  sameersbn/owncloud:latest \
  echo "Data-only container with owncloud source"
```

Will create a data-only owncloud container exposing the owncloud source. The container will also install a virtual host configuration for nginx via the `nginxSites` volume import. The `OWNCLOUD_FQDN` variable is used to configure the `server_name` variable in the virtual host configuration. If a configuration with the name `ownCloud` already exists it will not be overwritten. Owncloud data will be stored in the volume mounted at `/var/lib/owncloud`.

```bash
# create php-fpm container
docker run -d --name=phpFpm \
  --link postgresql:postgresql \
  --volumes-from owncloud \
  sameersbn/php5-fpm:latest
```

Will create a `php-fpm` container for use with owncloud. As with the case of the `postgresql` container, it can be used as a regular `php-fpm` server for other applications if desired. The link to `postgresql` allows us to use the hostname `postgresql` while specifying the database connection parameters in the owncloud setup. The `owncloud` volume import makes the owncloud source available to the `phpFpm` container.

```bash
# create nginx container
docker run -d --name=nginx \
  --publish 80:80 \
  --link phpFpm:php-fpm \
  --volumes-from nginxSites \
  --volumes-from owncloud \
  sameersbn/nginx:latest
```

Will create a `nginx` container and listen on host port `80`. If port `80` is already in use, then you can change the host port in the above command. The owncloud virtual host configuration will already be available in the `nginxSites` volume as it will be installed by the `owncloud` container in the previous commands. The `php-fpm` link alias will allow the nginx container to address the `phpFpm` container using the `php-fpm` hostname. The `owncloud` volume import will make the owncloud source available to the nginx container, thereby allowing it to handle requests to static site assets. The `nginx` container can be used for hosting other applications or act as a load balancer and can be treated as a generic `nginx` container just like the `postgresql` and `php-fpm` containers.

All of the above setup can be achived using `docker-compose-shared-workers.yml` file present in this repository. Make sure you update the `OWNCLOUD_FQDN` in the `docker-compose-shared-workers.yml` file before starting it up

# Final Steps

Once all the containers have been started, access your owncloud installation at `http://localhost` or `http://owncloud.example.com`. On first run, owncloud will ask you to create an admin user and specify the database connection parameters. Here select `Postgresql` and specify the hostname as `postgresql` and enter the details as specified in the command to start the `postgresql` container above. And you are done.

The `postgresql`, `php-fpm` and `nginx` containers are not specific to the owncloud installation and can be re-used with other applications as well.

