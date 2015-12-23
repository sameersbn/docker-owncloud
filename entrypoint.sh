#!/bin/bash
set -e

. ${OWNCLOUD_RUNTIME_DIR}/functions

case ${1} in
  app:owncloud)

    initialize_system
    configure_owncloud
    configure_nginx

    case ${1} in
      app:owncloud)
        exec /usr/sbin/php5-fpm
        ;;
    esac
    ;;
  app:help)
    echo "Available options:"
    echo " app:owncloud   - Starts the ownCloud server (default)"
    echo " app:help       - Displays the help"
    echo " [command]      - Execute the specified command, eg. bash."
    ;;
  *)
    exec "$@"
    ;;
esac
