#!/bin/bash
#
# Description : Install Owncloud 8 with NginX and SSL
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 0.8.3 (12/Sep/16)
#
# HELP        · https://doc.owncloud.org/server/8.0/admin_manual/release_notes.html
# 			  · https://geekytheory.com/tutorial-raspberry-pi-2-crea-tu-propia-nube-con-owncloud/
# 			  · http://www.pihomeserver.fr/en/2014/08/11/raspberry-pi-home-server-installer-owncloud-7-en-https-nginx/
# 			  · http://raspberrypihelp.net/tutorials/33-raspberry-pi-owncloud
# 			  · http://doc.owncloud.org/server/5.0/admin_manual/installation/installation_others.html
# 			  · http://www.surject.com/setup-owncloud-7-server-nginx-ubuntu/
#
clear



FILE="owncloud-9.1.0.tar.bz2"
URL_OWNCLOUD="http://download.owncloud.org/community/$FILE"
VERSION="ownCloud 8.0.2"
INSTALL_PACKAGES="php5 php5-json php-xml-parser php5-gd curl libcurl3 libcurl4-openssl-dev php5-curl php5-common sqlite3 php5-sqlite php-apc"

webserver_default(){
	sudo mkdir -p /var/www/html && cd /var/www/html
	sudo wget $URL_OWNCLOUD
	sudo tar xjvf owncloud-*.tar.bz2
	sudo rm $FILE
	sudo groupadd www-data
	sudo usermod -a -G www-data www-data
	sudo chown -R www-data:www-data /var/www/html/owncloud
}

mkSSLCert(){
	#method 1
	openssl req $@ -new -x509 -days 730 -nodes -out /etc/nginx/cert.pem -keyout /etc/nginx/cert.key
	sudo chmod 600 /etc/nginx/cert.pem
	sudo chmod 600 /etc/nginx/cert.key
	#method 2
	# mkdir -p /etc/nginx/certs && cd $_
	# openssl genrsa -des3 -out owncloud.key 1024
	# openssl req -new -key owncloud.key -out owncloud.csr
	# cp owncloud.key{,.org}
	# openssl rsa -in owncloud.key.org -out owncloud.key
	# openssl x509 -req -days 365 -in owncloud.csr -signkey owncloud.key -out owncloud.crt
	# rm owncloud.csr owncloud.key.org
}

Nginx(){
	clear
	echo -e "Installing $VERSION with NginX\n=====================================\n\n Please wait...\n"
	sudo apt-get install -y $INSTALL_PACKAGES nginx php5-fpm
	webserver_default
	#mkSSLCert
	if [[ -e /etc/nginx/sites-available/default ]]; then
		sudo mv /etc/nginx/sites-available/default{,.old}
	fi
	if [[ -e /etc/php5/fpm/php.ini ]]; then
		sudo sed -i -e 's/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=1/ig' /etc/php5/fpm/php.ini
	fi

	#cp ../../res/owncloud /etc/nginx/sites-available/owncloud
	#ln -s /etc/nginx/sites-available/owncloud /etc/nginx/sites-enabled/owncloud
	# /etc/PHP5/fpm/PHP.ini
	# upload_max_filesize = 700M
	# post_max_size = 800M
	sudo /etc/init.d/php5-fpm reload && sudo /etc/init.d/nginx reload
	sudo systemctl restart nginx && sudo systemctl restart php5-fpm
}

Apache2(){
	clear
	echo -e "Installing $VERSION with Apache2\n======================================\n\n· Aprox. 45.3 MB of additional disk space will be used.\n\nPlease wait...\n"
	sudo apt install -y $INSTALL_PACKAGES apache2 libapache2-mod-php5
	webserver_default
}

# For debug purpose
RemoveALL(){
	sudo apt-get remove -y php5 php5-json php-xml-parser php5-gd curl libcurl3 libcurl3-dev php5-curl php5-common sqlite php5-sqlite php-apc apache2 libapache2-mod-php5 nginx
	sudo apt-get autoremove -y
	sudo rm -rf /var/www
}

dialog   --title     "[ $VERSION with sqlite ]" \
         --yes-label "Nginx with SSL" \
         --no-label  "Apache2" \
         --yesno     "What kind of web server do you prefer?" 6 43

retval=$?

case $retval in
  0)   Nginx ;;
  1)   Apache2 ;;
esac

echo -e 'Done. Now restart the system and go to another device/PC and type in your Web browser: http://'$(hostname -I)'/owncloud'
read -p 'Press [ENTER] to continue...'
