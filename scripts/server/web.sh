#!/bin/bash
#
# Description : Install Web Server + php
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 0.8.1 (13/Aug/14)
#
# TODO        · Select another web server: nginx, cherokkee, lighhttpd
#             · Cherekee: http://www.drentsoft.com/linux-experiments/2014-01-03/quickest-way-to-install-cherokee-web-server/
#             · http://apsvr.com/blog/?p=73
#             · http://www.raspberrypi.org/forums/viewtopic.php?f=66&t=61778
#
clear

tempfile=`tempfile 2>/dev/null` || tempfile=/tmp/test$$
nginx_url='http://nginx.org/download/nginx-1.6.2.tar.gz'

apache(){
    clear
    echo "Installing Apache+PHP5..."
    sudo addgroup www-data
    sudo usermod -a -G www-data www-data
    sudo apt-get install -y apache2 php5 libapache2-mod-php5
    sudo service apache2 restart
    sudo /etc/init.d/apache2 restart

    cd /var/www
    sudo chown -R $USER: .

     echo "<?php phpinfo(); ?>" | sudo tee /var/www/phpinfo.php
}

monkey(){
    dialog --backtitle "PiKISS" \
         --title     "[ SSL ]" \
         --yes-label "Yes" \
         --no-label  "No" \
         --yesno     "Do you want SSL support?\nPress [ESC] to Cancel." 7 55

  retval=$?

  case $retval in
    0) local SSL_ENABLED="" ;;
    1) local SSL_ENABLED="monkey-polarssl libpolarssl0" ;;
  esac
    
    echo -e "deb http://packages.monkey-project.com/primates_pi primates_pi main" | sudo tee -a /etc/apt/sources.list
    sudo apt-get update && sudo apt-get install -y monkey monkey-liana monkey-logger monkey-dirlisting monkey-cgi monkey-fastcgi monkey-mandril monkey-cheetah monkey-auth $SSL_ENABLED
    curl -i http://$(ifconfig eth0 | sed -n 's/.*inet:\([0-9.]\+\)\s.*/\1/p'):2001/
    read -p "Done!. Press [Enter] to continue..."
}

nginx(){
  sudo apt-get install -y nginx php5-common php5-mysql php5-xmlrpc php5-cgi php5-curl php5-gd php5-cli php5-fpm php-apc php5-dev php5-mcrypt
}
build_nginx(){
  clear
  echo -e "Compiling NGINX with SSL, SPDY support, Automatic compression of static files & Decompression on the fly of compressed responses. Please wait...\n\n"
  cd $HOME
  sudo apt-get install -y make gcc libpcre3 libpcre3-dev zlib1g-dev libbz2-dev libssl-dev
  wget $nginx_url
  tar zxvf nginx*.tar.gz
  cd nginx*
  ./configure --with-http_gzip_static_module --with-http_gunzip_module --with-http_spdy_module --with-http_ssl_module
  make
  sudo make install
}

while true
do
	dialog --backtitle "PiKISS" \
		--title 	"[ Install Web Server ]" --clear \
		--menu  	"Pick one:" 15 55 5 \
        	Apache  	"Apache" \
              Monkey        "Monkey HTTP" \
              NGINX         "Nginx" \
            	NGINX_BUILD  	"Nginx (compile latest version)" \
            	Exit        	"Exit" 2>"${tempfile}"

	menuitem=$(<"${tempfile}")

	case $menuitem in
        	Apache) apache ;;
          Monkey) monkey ;;
          NGINX) nginx ;;
        	NGINX_BUILD) build_nginx ;;
        	Exit) exit ;;
	esac
done
