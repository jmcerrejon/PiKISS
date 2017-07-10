#!/bin/bash
#
# Description : Install a Framework,CMS to the web server
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 0.6 (10/Jul/17)
#
# Help        · Wordpress: https://github.com/raspberrypi/documentation/blob/master/usage/wordpress.md
#             ·     Ghost: http://geekytheory.com/ghost-blog-en-raspberry-pi/
#             ·   PyPlate: http://pplware.sapo.pt/linux/dica-como-ter-o-seu-proprio-site-no-raspberry-pi/
#
clear

URL_GHOST="https://github.com/TryGhost/Ghost/releases/download/0.11.10/Ghost-0.11.10.zip"
URL_WORDPRESS="https://wordpress.org/latest.tar.gz"
URL_NODEJS="https://nodejs.org/dist/latest/node-v8.1.3-linux-armv7l.tar.gz"

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
    sudo tar xvzf /usr/local/${URL_NODEJS##*/} --strip=1
    sudo rm /usr/local/${URL_NODEJS##*/}
    # Update if old version is installed
    sudo npm cache clean -f
    sudo npm install -g n
    sudo n stable
    echo "Press [Control+D] to return as normal user..."
    node --version
}

ghost(){
    sudo mkdir -p /var/www/ghost
    cd /var/www/ghost
    sudo chown $USER: .
    wget -qO- -O tmp.zip $URL_GHOST && unzip -o tmp.zip && rm tmp.zip
    sudo npm install --production
    sudo npm start
}

read -p "Wordpress (latest)? [y/n]" option
case "$option" in
    y*) wordpress ;;
esac

read -p "Node.js (latest)? [y/n]" option
case "$option" in
    y*) nodejs ;;
esac

read -p "GHOST (${URL_GHOST##*/})? [y/n]" option
case "$option" in
    y*) ghost ;;
esac
