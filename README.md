
**EXPERIMENTAL: Please do not use in production**

This is an experimental image intended for learning/demonstration of docker volumes. This is more of a proof of concept image and not intended to be used in production at this time.

Before we get into the nitty-gritties, lets take care of a few questions you may have.

*Does it work?*

Yes

*Should I use it in production?*

Not at this time. Only use it if you want to provide feedback or if you want to contribute or understand how all of this works together and then maybe use this information while building your own containers.

*What does not work?*

- You *cannot* install external plugins
- SSL support is not enabled, you need to do it manually and on your own

Now lets get started. We start by creating data-only containers to isolate data from the various containers as much as we can so that we only expose as much as we need to.

```bash
# create data-only container for php-fpm socket
docker run -d --name=phpSocket \
  --volume /srv/docker/owncloud/php5-fpm:/var/run/php5-fpm \
  busybox:latest \
    echo "Data-only container for php5-fpm socket"
```

Will create a data-only container for the php-fpm socket. This will later be used by the nginx container to proxy connections to the php-fpm container.

```bash
# create data-only container for nginx sites configuration
docker run -d --name=nginxSites \
  --volume /srv/docker/owncloud/nginx/sites-enabled:/etc/nginx/sites-enabled \
  busybox:latest \
    echo "Data-only container for nginx sites configuration"
```

Will create a data-only container for nginx site configurations. The owncloud container will automatically install a vhost configuration for accessing owncloud at this volume.

```bash
# create data-only container for ownCloud data
docker run -d --name=owncloudData \
  --volume /srv/docker/owncloud/owncloud:/data \
  busybox:latest \
    echo "Data-only container for ownCloud data"
```

Will create a data-only container for owncloud data.

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
  --volumes-from owncloudData \
  --volumes-from nginxSites \
  sameersbn/owncloud:latest \
    echo "Data-only container with owncloud source"
```

Will create the owncloud container exposing the owncloud source. The container will also install a virtual host configuration for nginx via the `nginxSites` volume import. The `OWNCLOUD_FQDN` variable is used to configure the `server_name` variable in the virtual host configuration. If a configuration with the name `ownCloud` already exists it will not be overwritten. Here the `postgresql` link and the `owncloudData` volume import options are not really required as we cannot automatically configure owncloud using the `postgresql` link.

```bash
# create php-fpm container
docker run -d --name=phpFpm \
  --link postgresql:postgresql \
  --volumes-from phpSocket \
  --volumes-from owncloud \
  sameersbn/php5-fpm:latest
```

Will create a `php-fpm` container for use with owncloud. As with the case of the `postgresql` container, it can be used as a regular `php-fpm` server for other applications if desired. The link to `postgresql` allows us to use the hostname `postgresql` while specifying the database connection parameters in the owncloud setup. The `php-fpm` unix domain socket will be created and available at the `phpSocket` volume import. The `owncloud` volume import makes the owncloud source available to the `phpFpm` container.

```bash
# create nginx container
docker run -d --name=nginx \
  --publish 80:80 \
  --volumes-from phpSocket \
  --volumes-from nginxSites \
  --volumes-from owncloud \
  sameersbn/nginx:latest
```

Will create a `nginx` container and listen on host port `80`. If port `80` is already in use, then you can change the host port in the above command. The owncloud virtual host configuration will already be available in the `nginxSites` volume as it will be installed by the `owncloud` container in the previous commands. The `phpSocket` volume import will allow nginx to talk to the `phpFpm` container via the `php-fpm` unix domain socket. The `owncloud` volume import will make the owncloud source available to the nginx container, thereby allowing it to handle requests to static site assets. The `nginx` container can be used for hosting other applications or act as a load balancer and can be treated as a generic `nginx` container just like the `postgresql` and `php-fpm` containers.

Once all the containers have been started, access your owncloud installation at `http://localhost` or `http://owncloud.example.com`. On first run, owncloud will ask you to create an admin user and specify the database connection parameters. Here select `Postgresql` and specify the hostname as `postgresql` and enter the details as specified in the command to start the `postgresql` container above. And you are done.

All of the above setup can be achived using `docker-compose.yml` file present in this repository. Make sure you update the `OWNCLOUD_FQDN` in the `docker-compose.yml` file before starting it up

As already mentioned the `postgresql`, `php-fpm` and `nginx` containers are not specific to the owncloud installation and can be re-used with other applications as well.
