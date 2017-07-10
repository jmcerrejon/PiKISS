#!/bin/bash
#
# Description : Install Web Server + php7
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 1.0 (10/Jul/17)
#
# TODO
#             · Cherekee: http://www.drentsoft.com/linux-experiments/2014-01-03/quickest-way-to-install-cherokee-web-server/
#             · http://apsvr.com/blog/?p=73
#             · http://www.raspberrypi.org/forums/viewtopic.php?f=66&t=61778
#             · http://underc0de.org/foro/seguridad-en-servidores/optimizando-al-maximo-apache/?PHPSESSID=3prm2i3bth04nqtcu2la6d74f2
#             · https://www.jeremymorgan.com/blog/programming/how-to-set-up-free-ssl/
#
clear
. ../helper.sh || . ./scripts/helper.sh || . ./helper.sh || wget -q 'http://github.com/jmcerrejon/PiKISS/raw/master/scripts/helper.sh'
check_board || { echo "Missing file helper.sh. I've tried to download it for you. Try to run the script again." && exit 1; }

tempfile=$(mktemp)
nginx_url='http://nginx.org/download/nginx-1.12.0.tar.gz'

nginx_ssl(){
  nginx
  git clone https://github.com/letsencrypt/letsencrypt letsencrypt && cd $_ || exit
  ./letsencrypt-auto --help

  dialog --inputbox "Enter your domain with no www (Example: misapuntesde.com):" 8 40 2>"${DOMAIN}"
  sudo $HOME/.local/share/letsencrypt/bin/letsencrypt certonly --webroot -w /var/www/html -d "$(<'${tempfile}')" -d www."$(<'${DOMAIN}')"
}

apache(){
  add_php7_repository
  clear
  echo "Installing Apache+PHP7..."
  sudo addgroup www-data
  sudo usermod -a -G www-data www-data
  sudo apt install -y apache2 php7.0 libapache2-mod-php7.0
  sudo systemctl restart apache2

  cd /var/www/ || return
  sudo chown -R $USER: .

  echo "<?php phpinfo(); ?>" | sudo tee /var/www/html/phpinfo.php
}

monkey(){
  HOST="$(hostname -I)"
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
  sudo apt-get update
  sudo apt install -y monkey-liana monkey-logger monkey-dirlisting monkey-cgi monkey-fastcgi monkey-mandril monkey-cheetah monkey-auth $SSL_ENABLED
  curl -i http://"$HOST)":2001/
  read -p "Done!. Press [Enter] to continue..."
}

nginx(){
  PACKAGES="nginx php7-common php7-mysql php7-xmlrpc php7-cgi php7-curl php7-gd php7-cli php7-fpm php-apc php7-dev php7-mcrypt"
  add_php7_repository
  sudo apt-get install -y $PACKAGES
}


build_nginx(){
  clear
  echo -e "Compiling NGINX with SSL, SPDY support, Automatic compression of static files & Decompression on the fly of compressed responses. Please wait...\n\n"
  cd $HOME || exit
  sudo apt-get install -y make gcc libpcre3 libpcre3-dev zlib1g-dev libbz2-dev libssl-dev
  wget $nginx_url
  tar zxvf nginx*.tar.gz
  cd nginx* || exit
  ./configure --with-http_gzip_static_module --with-http_gunzip_module --with-http_spdy_module --with-http_ssl_module
  make
  sudo make install
}

while true
do
  dialog --backtitle "PiKISS" \
  --title 	"[ Install Web Server ]" --clear \
  --menu  	"Pick one:" 15 55 6 \
  Apache  	"Apache" \
  Monkey        "Monkey HTTP" \
  NGINX         "Nginx ()" \
  NGINX_SSL     "Nginx with Let's Encrypt (Not tested)" \
  NGINX_BUILD  	"Nginx (compile version 1.12.0)" \
  Exit        	"Exit" 2>"${tempfile}"

  menuitem=$(<"${tempfile}")

  case $menuitem in
    Apache) apache ;;
    Monkey) monkey ;;
    NGINX) nginx ;;
    NGINX_SSL) nginx_ssl ;;
    NGINX_BUILD) build_nginx ;;
    Exit) exit ;;
  esac
done
