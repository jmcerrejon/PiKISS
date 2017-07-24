#!/bin/bash
#
# Description : Install Owncloud 10 with NginX and SSL
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 0.9.2 (24/Jul/17)
#
# HELP        · https://doc.owncloud.org/server/8.0/admin_manual/release_notes.html
# 			  		· https://geekytheory.com/tutorial-raspberry-pi-2-crea-tu-propia-nube-con-owncloud/
# 			  		· http://www.pihomeserver.fr/en/2014/08/11/raspberry-pi-home-server-installer-owncloud-7-en-https-nginx/
# 			  		· http://raspberrypihelp.net/tutorials/33-raspberry-pi-owncloud
# 			  		· http://doc.owncloud.org/server/5.0/admin_manual/installation/installation_others.html
# 			  		· http://www.surject.com/setup-owncloud-7-server-nginx-ubuntu/
#
clear
. ../helper.sh || . ./scripts/helper.sh || . ./helper.sh || wget -q 'http://github.com/jmcerrejon/PiKISS/raw/master/scripts/helper.sh'
check_board || { echo "Missing file helper.sh. I've tried to download it for you. Try to run the script again." && exit 1; }

FILE="owncloud-10.0.2.tar.bz2"
URL_OWNCLOUD="http://download.owncloud.org/community/$FILE"
VERSION="ownCloud 10.0.2"
INSTALL_PACKAGES="php7.0 php7.0-json php-xml-parser php7.0-gd php7.0-zip php7.0-mbstring curl libcurl3 libcurl4-openssl-dev php7.0-curl php7.0-common sqlite3 php7.0-sqlite3 php7.0-opcache"
IP=$(get_ip)

webserver_default(){
	directory_exist /var/www/html/owncloud
	sudo mkdir -p /var/www/html && cd $_ || exit
	sudo wget $URL_OWNCLOUD
	echo "Uncompressing. Please wait..."
	sudo tar xjf owncloud-*.tar.bz2
	sudo rm $FILE
	sudo groupadd www-data
	sudo usermod -a -G www-data www-data
	sudo chown -R www-data:www-data /var/www/html/owncloud
}

mkSSLCert(){
	#method 1
	openssl req "$@" -new -x509 -days 730 -nodes -out /etc/nginx/cert.pem -keyout /etc/nginx/cert.key
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
	add_php7_repository
	sudo apt install -y $INSTALL_PACKAGES nginx php7.0-fpm
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
	echo -e "Installing $VERSION with Apache2\n=======================================\n\n· Aprox. 45.3 MB of additional disk space will be used.\n\nPlease wait...\n"
	command -v apache2 >/dev/null 2>&1 || install_apache2
	add_php7_repository
	sudo apt install -y "$INSTALL_PACKAGES"
	php_file_max_size
	webserver_default
}

# For debug purpose
RemoveALL(){
	sudo apt-get remove -y "$INSTALL_PACKAGES" apache2 libapache2-mod-php7.0 nginx
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

echo -e "Done. Now restart the system and go to another device/PC and type in your Web browser: http://${IP}/owncloud"
read -p 'Press [ENTER] to continue...'
