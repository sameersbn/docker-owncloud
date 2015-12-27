[![Docker Repository on Quay.io](https://quay.io/repository/sameersbn/owncloud/status "Docker Repository on Quay.io")](https://quay.io/repository/sameersbn/owncloud)

**EXPERIMENTAL: Please do not use in production**

- [Introduction](#introduction)
- [Quicktart](#quickstart)
- [Final Steps](#final-steps)

# Introduction

This is an experimental image. This is more of a proof of concept image and not intended to be used in production at this time.

Before we get into the nitty-gritties, lets take care of a few questions you may have.

*Does it work?*

Yes

*Can I use it in production?*

Not at this time. Only use it if you want to provide feedback or if you want to contribute or understand how all of this works together and then maybe use this information while building your own containers.

Since this is a study exercise at the moment the image will change significantly over a period of time.

*What does not work?*

- You *cannot* install external plugins
- SSL support is not enabled, you need to configure SSL termination at the load-balancer.

# Quickstart

The quickest way to get started is using [docker-compose](https://docs.docker.com/compose/).

```bash
wget https://raw.githubusercontent.com/sameersbn/docker-owncloud/master/docker-compose.yml
```

Edit `docker-compose.yml` and update `OWNCLOUD_URL` with the url from which ownCloud will be externally accessible.

Start ownCloud using:

```bash
docker-compose up
```

Alternatively, you can manually launch the `owncloud` container and the supporting `postgresql` and `nginx` services by following this three step guide.

Step 1. Launch a postgresql container

```bash
docker run --name owncloud-postgresql -itd --restart=always \
  --env 'DB_NAME=owncloud_db' \
  --env 'DB_USER=owncloud' --env 'DB_PASS=password' \
  --volume /srv/docker/owncloud/postgresql:/var/lib/postgresql \
  sameersbn/postgresql:9.4-11
```

Step 2. Launch the owncloud service

```bash
docker run --name=owncloud -itd --restart=always \
  --env OWNCLOUD_URL=http://cloud.damagehead.com:10080 \
  --link owncloud-postgresql:postgresql \
  --volume /srv/docker/owncloud/owncloud:/var/lib/owncloud \
  sameersbn/owncloud:latest app:owncloud
```

Step 3. Launch the nginx frontend

```bash
docker run --name=owncloud-nginx -itd --restart=always -p 10080:80 \
  --link owncloud:owncloud-php-fpm \
  sameersbn/owncloud:latest app:nginx
```

Point your browser to `http://cloud.example.com:10080` and complete the setup by creating a user.
