#!/bin/bash
#
# Description : Install a Framework,CMS to the web server
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 0.3 (12/Jun/14)
#
# Help        · Wordpress: https://github.com/raspberrypi/documentation/blob/master/usage/wordpress.md
#             ·     Ghost: http://geekytheory.com/ghost-blog-en-raspberry-pi/
#             ·   PyPlate: http://pplware.sapo.pt/linux/dica-como-ter-o-seu-proprio-site-no-raspberry-pi/
#
# IMPROVEMENT · Install Nodejs if framework need it
#
clear

URL_GHOST="https://ghost.org/zip/ghost-0.4.2.zip"
URL_WORDPRESS="https://wordpress.org/latest.tar.gz"
URL_NODEJS="http://nodejs.org/dist/v0.10.26/node-v0.10.26-linux-arm-pi.tar.gz"

wordpress(){
    cd /var/www
    sudo chown $USER: .
    wget $URL_WORDPRESS
    tar xzf ${URL_WORDPRESS##*/}
    rm ${URL_WORDPRESS##*/}
    echo "Installed on /var/www/wordpress directory"
}

nodejs(){
    cd /usr/local
    sudo wget $URL_NODEJS
    sudo tar xvzf ~/${URL_NODEJS##*/} --strip=1
    echo "Press [Control+D] to return as normal user..."
    node --version
}

ghost(){
    sudo mkdir -p /var/www/ghost
    cd /var/www/ghost
    sudo chown $USER: .
    wget -qO- -O tmp.zip $URL_GHOST && unzip -o tmp.zip && rm tmp.zip
    sudo npm install --production
    read -p "Website accesible from remote (default:only localhost)? [y/n]" option
    case "$option" in
        y*) wordpress ;;
    esac
    sudo npm start
}

read -p "Wordpress (latest)? [y/n]" option
case "$option" in
    y*) wordpress ;;
esac

read -p "Node.js (0.10.26)? [y/n]" option
case "$option" in
    y*) nodejs ;;
esac

read -p "GHOST (${URL_GHOST##*/})? [y/n]" option
case "$option" in
    y*) ghost ;;
esac
