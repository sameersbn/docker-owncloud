#!/bin/bash
set -e

. ${OWNCLOUD_RUNTIME_DIR}/functions

install_vhost

initialize_volumes

configure_owncloud

exec $@
