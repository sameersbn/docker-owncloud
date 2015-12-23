#!/bin/bash
set -e
source ${OWNCLOUD_RUNTIME_DIR}/functions

[[ $DEBUG == true ]] && set -x

case ${1} in
  app:owncloud|occ)

    initialize_system
    configure_owncloud
    configure_nginx

    case ${1} in
      app:owncloud)
        exec /usr/sbin/php5-fpm
        ;;
      occ)
        exec $@
        ;;
    esac
    ;;
  app:help)
    echo "Available options:"
    echo " app:owncloud   - Starts the ownCloud server (default)"
    echo " occ            - Launch the ownCloud's command-line interface"
    echo " app:help       - Displays the help"
    echo " [command]      - Execute the specified command, eg. bash."
    ;;
  *)
    exec "$@"
    ;;
esac
