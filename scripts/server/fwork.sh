#!/bin/bash
#
# Description : Install a Framework,CMS to the web server
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 1.0.0 (20/Oct/21)
#
# Help
#             · https://darryldias.me/wordpress-with-sqlite/
#             · https://docs.ghost.org/docs/installing-ghost-via-the-cli#pre-requisites
#             · https://www.nginx.com/resources/wiki/start/topics/recipes/wordpress/
#             · https://user-meta.com/blog/light-weight-install-wordpress-sqlite/
# TODO        · Uninstall Nginx (WordPress), Open Browser & VSCode
#
clear

. ../helper.sh || . ./scripts/helper.sh || . ./helper.sh || wget -q 'https://github.com/jmcerrejon/PiKISS/raw/master/scripts/helper.sh'
check_board || { echo "Missing file helper.sh. I've tried to download it for you. Try to run the script again." && exit 1; }

readonly LATEST_WORDPRESS_URL="https://wordpress.org/latest.tar.gz"
readonly WWW_PATH="/var/www/html"
readonly GHOST_REPOSITORY_NAME="TryGhost/Ghost"
readonly WP_INSTALL_PATH="${WWW_PATH}/wordpress"
readonly DEFAULT_NGINX_SITE_CONFIG_FILE_PATH="/etc/nginx/sites-available/default"
DEFAULT_NGINX_SITES_AVAILABLE_DIR="/etc/nginx/sites-available"
IP=$(get_ip)
tempfile=$(mktemp)

wordpress_uninstall() {
    [[ -d $WP_INSTALL_PATH ]] && sudo rm -rf $WP_INSTALL_PATH
    uninstall_mariadb

    echo
    read -p "Do you want to remove Nginx and PHP from your system? (Y/n) " response
    if [[ $response =~ [Yy] ]]; then
        sudo apt remove -y nginx-light php*
    fi

    echo -e "\nUninstalled. It recommended to restart."
}

copy_default_wordpress_site() {
    echo -e "\nCopying default site from $PIKISS_DIR/res/default.nginx to $DEFAULT_NGINX_SITE_CONFIG_FILE_PATH..."
    if [[ -w $DEFAULT_NGINX_SITES_AVAILABLE_DIR ]]; then
        mv "/etc/nginx/sites-available/default" "/etc/nginx/sites-available/default.bak"
        cp "/home/pi/pikiss/res/default.nginx" "/etc/nginx/sites-available/default"
        mv "$DEFAULT_NGINX_SITE_CONFIG_FILE_PATH" "$DEFAULT_NGINX_SITE_CONFIG_FILE_PATH.bak"
        cp "$PIKISS_DIR/res/default.nginx" "$DEFAULT_NGINX_SITE_CONFIG_FILE_PATH"
    else
        echo -e "ERROR: Could not copy the file. You need to setting up Nginx manually or copy the file by yourself."
    fi
    sudo systemctl restart nginx
}

wordpress() {
    local WP_SITE
    local WP_SITE_LOCAL
    WP_SITE="http://${IP}/wordpress"
    WP_SITE_LOCAL="http://127.0.0.1/wordpress"

    if [[ -e $WP_INSTALL_PATH ]]; then
        read -p "WordPress site already installed. Do you want to delete it? (Y/n) " response
        if [[ $response =~ [Nn] ]]; then
            exit_message
        fi

        wordpress_uninstall
        exit_message
    fi

    install_script_message
    echo -e "\nInstalling WordPress and dependencies...\n"
    install_php 7
    install_nginx
    install_mariadb
    copy_default_wordpress_site

    echo -e "Searching latest WordPress installation files ...\n"
    download_and_extract "$LATEST_WORDPRESS_URL" "${WWW_PATH}"

    wordpress_post_install
    open_default_browser "$WP_SITE_LOCAL"

    echo -e "\nDone!. Wordpress installed at $WP_INSTALL_PATH. You can access through the following URL\nYour Pi: $WP_SITE_LOCAL\nRemote local computer: $WP_SITE"
    exit_message
}

wordpress_post_install() {
    sudo mysql -e "CREATE DATABASE wordpress; GRANT ALL PRIVILEGES ON wordpress.* TO '${USER}'@'%'; FLUSH PRIVILEGES;"
    sudo chown -R www-data: "$WP_INSTALL_PATH"
    sudo find "${WWW_PATH}" -type d -exec chmod 755 {} \;
    sudo find "${WWW_PATH}" -type f -exec chmod 644 {} \;
}

nodejs() {
    install_node
    exit_message
}

ghost() {
    local GHOST_LATEST_RELEASE_VERSION
    GHOST_LATEST_RELEASE_VERSION=$(get_latest_release $GHOST_REPOSITORY_NAME)
    local GHOST_LATEST_RELEASE_URL="https://github.com/TryGhost/Ghost/releases/download/$GHOST_LATEST_RELEASE_VERSION/Ghost-$GHOST_LATEST_RELEASE_VERSION.zip"
    install_node 14
    sudo mkdir -p "${WWW_PATH}" && cd "$_" || exit 1
    sudo chown "$USER:" .
    download_and_extract "$GHOST_LATEST_RELEASE_URL" "${WWW_PATH}"
    cd "${WWW_PATH}/ghost" || exit 1
    echo -e "\nInstalling Ghost, please wait...\n"
    sudo npm install --production --unsafe-perm
    sudo npm start
    read -p "Done!. Press [Enter] to continue..."
}

while true; do
    dialog --backtitle "PiKISS" --title "[ Install Framework ]" --clear --menu "Pick one:" 15 55 6 \
        Wordpress "Nginx+PHP 7.4+MariaDB (Latest)" \
        Node "Choose version" \
        Ghost "Ghost (Latest)" \
        Exit "Exit" 2>"${tempfile}"

    menuitem=$(<"${tempfile}")
    clear
    case $menuitem in
    Wordpress) wordpress ;;
    Node) nodejs ;;
    Ghost) ghost ;;
    Exit) exit ;;
    esac
done

rm "$tempfile"
