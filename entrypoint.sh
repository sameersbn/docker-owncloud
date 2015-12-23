#!/bin/bash
set -e

. ${OWNCLOUD_RUNTIME_DIR}/functions

install_vhost

initialize_system
configure_owncloud

exec $@
