#!/bin/bash
set -e

. /etc/owncloud/functions

install_vhost

initialize_volumes
configure_database
update_volume_version

exec $@
