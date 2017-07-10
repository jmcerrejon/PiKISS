#!/bin/bash
#
# Description : Install a Framework,CMS to the web server
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 0.7.1 (10/Jul/17)
#
# Help        · Wordpress: https://github.com/raspberrypi/documentation/blob/master/usage/wordpress.md
#             · PyPlate: http://pplware.sapo.pt/linux/dica-como-ter-o-seu-proprio-site-no-raspberry-pi/
#             · https://darryldias.me/wordpress-with-sqlite/
#
clear

URL_GHOST="https://github.com/TryGhost/Ghost/releases/download/0.11.10/Ghost-0.11.10.zip"
URL_WORDPRESS="https://wordpress.org/latest.tar.gz"
URL_NODEJS="https://nodejs.org/dist/latest/node-v8.1.3-linux-armv7l.tar.gz"

sqlite_integration(){
  WP_INSTALL="/var/www/html/wordpress"
  USER_DB="$USER/sc/db_wordpress"
  wget -P $WP_INSTALL/wp-content/plugins/ https://downloads.wordpress.org/plugin/sqlite-integration.1.8.1.zip
  unzip $WP_INSTALL/wp-content/plugins/sqlite*.zip
  cp $WP_INSTALL/wp-content/plugins/sqlite-integration/db.php ../../
  cp $WP_INSTALL/wp-config-sample.php ./wp-config.php
  sudo mkdir -p $USER/sc/db_wordpress
  echo "define('DB_FILE', 'wordpress');" >> $WP_INSTALL/wp-config.php
  echo "define('DB_DIR', '${USER_DB}'); " >> $WP_INSTALL/wp-config.php
  echo -e "SQLite integration installed.\n"
}

wordpress(){
  cd /var/www/html || return
  sudo chown $USER: .
  wget $URL_WORDPRESS
  tar xzf ${URL_WORDPRESS##*/}
  rm ${URL_WORDPRESS##*/}
  read -p "Enable SQLite integration? [y/n] " option
  case "$option" in
    y*) sqlite_integration ;;
  esac
  echo -e "Wordpress installed on /var/www/wordpress directory.\n"
}

nodejs(){
  cd /usr/local || exit
  sudo wget $URL_NODEJS
  sudo tar xvzf /usr/local/${URL_NODEJS##*/} --strip=1
  sudo rm /usr/local/${URL_NODEJS##*/}
  # Update if old version is installed
  sudo npm cache clean
  sudo npm install -g n
  sudo n stable
  echo "Press [Control+D] to return as normal user..."
  node --version
}

ghost(){
  sudo mkdir -p /var/www/html/ghost && cd $_ || return
  sudo chown $USER: .
  wget -qO- -O tmp.zip $URL_GHOST && unzip -o tmp.zip && rm tmp.zip
  sudo npm install --production --unsafe-perm
  sudo npm start
}

read -p "Wordpress (latest)? [y/n] " option
case "$option" in
  y*) wordpress ;;
esac

read -p "Node.js (latest)? [y/n] " option
case "$option" in
  y*) nodejs ;;
esac

read -p "GHOST (${URL_GHOST##*/})? [y/n] " option
case "$option" in
  y*) ghost ;;
esac
