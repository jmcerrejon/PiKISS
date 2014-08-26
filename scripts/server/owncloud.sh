#!/bin/bash
#
# Description : Install Owncloud 7 with NginX and SSL
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 0.7 (14/08/14)
#
# HELP        · http://www.pihomeserver.fr/en/2014/08/11/raspberry-pi-home-server-installer-owncloud-7-en-https-nginx/
# 			  · http://raspberrypihelp.net/tutorials/33-raspberry-pi-owncloud
# 			  · http://doc.owncloud.org/server/5.0/admin_manual/installation/installation_others.html
#
clear

URL_OWNCLOUD='http://download.owncloud.org/community/owncloud-7.0.1.tar.bz2'

echo -e "Installing Owncloud 7.0.1. with NginX\n=====================================\n\n Please wait...\n"
apt-get install -y nginx php5-fpm php5 php5-json php5-gd php5-sqlite curl libcurl3 libcurl3-dev php5-curl php5-common php-xml-parser sqlite php-apc
mkdir -p /var/www && cd $_
wget $URL_OWNCLOUD
tar xjvf owncloud-7.0.1.tar.bz2
chown -R www-data:www-data /var/www/owncloud
mkdir -p /etc/nginx/certs && cd $_
openssl genrsa -des3 -out owncloud.key 1024
openssl req -new -key owncloud.key -out owncloud.csr
cp owncloud.key owncloud.key.org
openssl rsa -in owncloud.key.org -out owncloud.key
openssl x509 -req -days 365 -in owncloud.csr -signkey owncloud.key -out owncloud.crt
rm owncloud.csr owncloud.key.org
cp ../../res/owncloud /etc/nginx/sites-available/owncloud
ln -s /etc/nginx/sites-available/owncloud /etc/nginx/sites-enabled/owncloud
chown -R www-data:www-data /var/www/owncloud
# /etc/PHP5/fpm/PHP.ini 
# upload_max_filesize = 700M 
# post_max_size = 800M
service nginx restart && service php5-fpm restart

echo -e 'Done. Go to another device/PC and type in your Web browser: http://'$(hostname -I)
read -p 'Press [ENTER] to continue...'