#!/bin/bash
#
# Description : Install Web Server (Apache, Nginx)
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 1.0.2 (22/Jan/23)
#
# HELP		  : https://www.digitalocean.com/community/tutorials/how-to-install-nginx-on-debian-11
#
clear
. ../helper.sh || . ./scripts/helper.sh || . ./helper.sh || wget -q 'https://github.com/jmcerrejon/PiKISS/raw/master/scripts/helper.sh'
check_board || { echo "Missing file helper.sh. I've tried to download it for you. Try to run the script again." && exit 1; }

tempfile=$(mktemp)
IP=$(get_ip)
NGINX_VERSION="1.23.3"
PHP_VERSION="8.2"
NGINX_SOURCE_CODE_URL="https://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz"
NGINX_PACKAGES=(nginx)
PHP74_PACKAGES=(php7.4 php7.4-common php7.4-mysql php7.4-xmlrpc php7.4-cgi php7.4-curl php7.4-gd php7.4-cli php7.4-fpm php7.4-dev php7.4-mcrypt)
PHP_PACKAGES=(nginx php"$PHP_VERSION"-common php"$PHP_VERSION"-mysql php"$PHP_VERSION"-xmlrpc php"$PHP_VERSION"-cgi php"$PHP_VERSION"-curl php"$PHP_VERSION"-gd php"$PHP_VERSION"-cli php"$PHP_VERSION"-fpm php"$PHP_VERSION"-dev php"$PHP_VERSION"-mcrypt)
APACHE_PACKAGES=(apache2 libapache2-mod-php7.4)

install_lets_encrypt() {
    git clone https://github.com/letsencrypt/letsencrypt letsencrypt && cd "$_" || exit
    ./letsencrypt-auto --help

    dialog --inputbox "Enter your domain with no www (Example: misapuntesde.com):" 8 40 2>"${DOMAIN}"
    sudo "$HOME/.local/share/letsencrypt/bin/letsencrypt" certonly --webroot -w /var/www/html -d "$(<'${tempfile}')" -d www."$(<'${DOMAIN}')"
}

add_phpinfo() {
    echo "<?php phpinfo(); ?>" | sudo tee /var/www/html/phpinfo.php
    echo "DONE! You can access to http://$IP/phpinfo.php"
}

apache() {
    clear
    # Check & remove Apache2
    if [[ -f /usr/sbin/apache2 ]]; then
        read -p "Apache2 + PHP 7.4 is installed. Do you want to remove it? (y/N) " response
        if [[ $response =~ [Yy] ]]; then
            sudo apt-get purge -y "${APACHE_PACKAGES[@]}"
            sudo apt-get purge -y "${PHP74_PACKAGES[@]}"
            sudo apt-get autoremove -y
            sudo apt-get autoclean -y
            sudo -rf /var/lib/php/modules/7.4/apache2 /etc/apache2 /var/log/apache2
            exit_message
        fi
    fi

    echo "Installing Apache + PHP 7.4"
    sudo addgroup www-data
    sudo apt install -y "${APACHE_PACKAGES[@]}"
    sudo apt install -y "${PHP74_PACKAGES[@]}"
    sudo usermod -a -G www-data www-data
    sudo systemctl restart apache2

    cd /var/www/ || return
    sudo chown -R "$USER": .

    add_phpinfo
    exit_message
}

configure_php_to_nginx() {
    LOCAL SITES_AVAILABLE_PATH="/etc/nginx/sites-available"
    if [[ ! -d /etc/nginx/sites-available/ ]]; then
        sudo mkdir -p "$SITES_AVAILABLE_PATH"
    fi
    sudo cp "$RESOURCES_DIR"/default.nginx "$SITES_AVAILABLE_PATH"/default
    sudo systemctl restart nginx
}

nginx() {
    clear
    # Check & remove Nginx
    if [[ -f /usr/sbin/nginx ]]; then
        read -p "Nginx is installed. Do you want to remove it? (y/N) " response
        if [[ $response =~ [Yy] ]]; then
            sudo apt-get purge -y "${NGINX_PACKAGES[@]}"
            sudo apt-get purge -y "${PHP_PACKAGES[@]}"
            sudo apt-get autoremove -y
            sudo apt-get autoclean -y
            sudo rm -rf /usr/sbin/nginx /etc/nginx /var/log/nginx /usr/share/nginx /usr/share/man/man8/nginx.8.gz
            exit_message
        fi
    fi
    sudo apt-get install -y "${NGINX_PACKAGES[@]}"
    echo
    # read -p "Do you want to install PHP $PHP_VERSION? (y/N) " response
    # if [[ $response =~ [Yy] ]]; then
    #     add_php_repository
    #     sudo apt-get install -y "${PHP_PACKAGES[@]}"
    #     add_phpinfo
    # fi
    systemctl status nginx
    echo "DONE! You can access to http://$IP"
    exit_message
}

build_nginx() {
    local BUILD_SOURCE_CODE_PATH="$HOME/sc"
    local BUILD_NGINX_PACKAGES=(make gcc libpcre3 libpcre3-dev zlib1g-dev libbz2-dev libssl-dev)

    clear
    echo -e "\nCompiling NGINX with SSL, SPDY support, Automatic compression of static files & Decompression on the fly of compressed responses. Please wait...\n\n"
    mkdir -p "$BUILD_SOURCE_CODE_PATH" && cd "$_" || exit
    sudo apt-get install -y "${BUILD_NGINX_PACKAGES[@]}"
    wget "$NGINX_SOURCE_CODE_URL" && tar -xzf "nginx*.tar.gz" || exit
    cd "nginx*" || exit
    ./configure --with-http_gzip_static_module --with-http_gunzip_module --with-http_spdy_module --with-http_ssl_module
    make_with_all_cores
    read -p "Do you want to install Nginx on your OS? (y/N) " response
    if [[ $response =~ [Yy] ]]; then
        make_install_compiled_app
    fi
}

while true; do
    dialog --backtitle "PiKISS" \
        --title "[ Install Web Server ]" --clear \
        --menu "Pick one:" 15 56 6 \
        Apache "Apache2 with PHP 7.4" \
        NGINX "Nginx from RPIOS repository" \
        NGINX_BUILD "Nginx (compile version ${NGINX_VERSION})" \
        LETS_ENCRYPT "Let's Encrypt (SSL)" \
        Exit "Exit" 2>"${tempfile}"

    menuitem=$(<"${tempfile}")

    case $menuitem in
    Apache) apache ;;
    NGINX) nginx ;;
    NGINX_BUILD) build_nginx ;;
    LETS_ENCRYPT) install_lets_encrypt ;;
    Exit) exit ;;
    esac
done
