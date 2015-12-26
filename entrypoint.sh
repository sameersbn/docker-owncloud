#!/bin/bash
set -e
source ${OWNCLOUD_RUNTIME_DIR}/functions

[[ $DEBUG == true ]] && set -x

case ${1} in
  app:owncloud|app:nginx|occ)

    initialize_system

    case ${1} in
      app:owncloud)
        configure_owncloud
        echo "Starting ownCloud php5-fpm..."
        exec $(which php5-fpm)
        ;;
      app:nginx)
        configure_nginx
        echo "Starting nginx..."
        exec $(which nginx) -c /etc/nginx/nginx.conf -g "daemon off;"
        ;;
      occ)
        exec $@
        ;;
    esac
    ;;
  app:help)
    echo "Available options:"
    echo " app:owncloud   - Starts the ownCloud php5-fpm server (default)"
    echo " app:nginx      - Starts the nginx server"
    echo " occ            - Launch the ownCloud's command-line interface"
    echo " app:help       - Displays the help"
    echo " [command]      - Execute the specified command, eg. bash."
    ;;
  *)
    exec "$@"
    ;;
esac
