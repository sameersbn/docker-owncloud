#!/bin/bash
set -e

. /etc/owncloud/functions

oc_install_vhost

oc_initialize_volumes
oc_configure_database
oc_update_volume_version

exec $@
