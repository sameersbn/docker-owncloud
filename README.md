
**EXPERIMENTAL: Please do not use in production**

This is an experimental image intended for learning/demonstration of docker volumes. This is more of a proof of concept image and not intended to be used in production at this time.

Before we get into the nitty-gritties, lets take care of a few questions you may have.

*Does it work?*

Yes

*Can I use it in production?*

Not at this time. Only use it if you want to provide feedback or if you want to contribute or understand how all of this works together and then maybe use this information while building your own containers.

*What does not work?*

- You *cannot* install external plugins
- SSL support is not enabled, you need to do it manually and on your own
- File upload size is limited to `2G`

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
  --volume /srv/docker/owncloud/owncloud:/data \
  --volumes-from nginxSites \
  sameersbn/owncloud:latest
```

Will create the owncloud container exposing the owncloud source. The container will also install a virtual host configuration for nginx via the `nginxSites` volume import. The `OWNCLOUD_FQDN` variable is used to configure the `server_name` variable in the virtual host configuration. If a configuration with the name `ownCloud` already exists it will not be overwritten. Owncloud data will be stored in the volume mounted at `/data`.

```bash
# create nginx container
docker run -d --name=nginx \
  --publish 80:80 \
  --volumes-from nginxSites \
  --volumes-from owncloud \
  sameersbn/nginx:latest
```

Will create a `nginx` container and listen on host port `80`. If port `80` is already in use, then you can change the host port in the above command. The owncloud virtual host configuration will already be available in the `nginxSites` volume as it will be installed by the `owncloud` container in the previous commands. The `owncloud` volume import will make the owncloud source available to the nginx container, thereby allowing it to handle requests to static site assets. This `nginx` container can be used for hosting other applications or act as a load balancer and can be treated as a generic `nginx` container just like the `postgresql` container.

Once all the containers have been started, access your owncloud installation at `http://localhost` or `http://owncloud.example.com`. On first run, owncloud will ask you to create an admin user and specify the database connection parameters. Here select `Postgresql` and specify the hostname as `postgresql` and enter the details as specified in the command to start the `postgresql` container above. And you are done.

All of the above setup can be achived using `docker-compose.yml` file present in this repository. Make sure you update the `OWNCLOUD_FQDN` in the `docker-compose.yml` file before starting it up

As already mentioned the `postgresql`, and `nginx` containers are not specific to the owncloud installation and can be re-used with other applications as well.
