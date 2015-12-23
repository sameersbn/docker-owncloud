#!/bin/bash
set -e

. ${OWNCLOUD_RUNTIME_DIR}/functions

initialize_system
configure_owncloud
configure_nginx

exec $@
