#!/bin/bash
set -e

. ${OWNCLOUD_RUNTIME_DIR}/functions

install_vhost

initialize_volumes
configure_database
update_volume_version

exec $@
