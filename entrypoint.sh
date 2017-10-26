#!/bin/bash
set -e
source ${OWNCLOUD_RUNTIME_DIR}/functions

[[ $DEBUG == true ]] && set -x

case ${1} in
  app:owncloud|app:nginx|app:backup:create|app:backup:restore|occ)

    initialize_system

    case ${1} in
      app:owncloud)
        configure_owncloud
        echo "Starting ownCloud php-fpm${PHP_VERSION}..."
        exec $(which php-fpm${PHP_VERSION}) -F
        ;;
      app:nginx)
        configure_nginx
        echo "Starting nginx..."
        exec $(which nginx) -c /etc/nginx/nginx.conf -g "daemon off;"
        ;;
      app:backup:create)
        shift 1
        backup_create
        ;;
      app:backup:restore)
        shift 1
        backup_restore $@
        ;;
      occ)
        exec $@
        ;;
    esac
    ;;
  app:help)
    echo "Available options:"
    echo " occ                  - Launch the ownCloud's command-line interface"
    echo " app:owncloud         - Starts the ownCloud php5-fpm server (default)"
    echo " app:nginx            - Starts the nginx server"
    echo " app:backup:create    - Create a backup"
    echo " app:backup:restore   - Restore an existing backup"
    echo " app:help             - Displays the help"
    echo " [command]            - Execute the specified command, eg. bash."
    ;;
  *)
    exec "$@"
    ;;
esac
