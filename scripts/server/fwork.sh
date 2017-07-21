#!/bin/bash
#
# Description : Install a Framework,CMS to the web server
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 0.7.3 (21/Jul/17)
#
# Help        · Wordpress: https://github.com/raspberrypi/documentation/blob/master/usage/wordpress.md
#             · PyPlate: http://pplware.sapo.pt/linux/dica-como-ter-o-seu-proprio-site-no-raspberry-pi/
#             · https://darryldias.me/wordpress-with-sqlite/
#             · https://docs.ghost.org/docs/installing-ghost-via-the-cli#pre-requisites
#
clear

. ../helper.sh || . ./scripts/helper.sh || . ./helper.sh || wget -q 'http://github.com/jmcerrejon/PiKISS/raw/master/scripts/helper.sh'
check_board || { echo "Missing file helper.sh. I've tried to download it for you. Try to run the script again." && exit 1; }

URL_GHOST="https://github.com/TryGhost/Ghost/releases/download/0.11.11/Ghost-0.11.11.zip"
URL_WORDPRESS="https://wordpress.org/latest.tar.gz"
WWW_PATH="/var/www/html"
tempfile=$(mktemp)

sqlite_integration(){
  WP_INSTALL="${WWW_PATH}/wordpress"
  USER_DB="$HOME/sc/db_wordpress"
  wget -P $WP_INSTALL/wp-content/plugins/ https://downloads.wordpress.org/plugin/sqlite-integration.1.8.1.zip
  cd $WP_INSTALL/wp-content/plugins || exit
  sudo apt install -y sqlite3 php7.0-sqlite3
  unzip $WP_INSTALL/wp-content/plugins/sqlite*.zip
  cp $WP_INSTALL/wp-content/plugins/sqlite-integration/db.php $WP_INSTALL/wp-content/db.php
  cp $WP_INSTALL/wp-config-sample.php $WP_INSTALL/wp-config.php
  mkdir -p $USER_DB
  echo "define('DB_FILE', 'wordpress');" >> $WP_INSTALL/wp-config.php
  echo "define('DB_DIR', '${USER_DB}'); " >> $WP_INSTALL/wp-config.php
  echo -e "SQLite integration installed.\n"
}

wordpress(){
  cd "${WWW_PATH}" || return
  sudo chown $USER: .
  wget $URL_WORDPRESS
  tar xzf ${URL_WORDPRESS##*/}
  rm ${URL_WORDPRESS##*/}
  sudo find "${WWW_PATH}" -type d -exec chmod 755 {} \;
  sudo find "${WWW_PATH}" -type f -exec chmod 644 {} \;
  read -p "Enable SQLite integration (not tested)? [y/n] " option
  case "$option" in
    y*) sqlite_integration ;;
  esac
  read -p "Wordpress installed on /var/www/html/wordpress directory. Press [Enter] to continue..."
}

nodejs(){
  install_node
  read -p "Done!. Press [Enter] to continue..."
}

ghost(){
  install_node 6
  sudo mkdir -p "${WWW_PATH}" && cd $_ || return
  sudo chown $USER: .
  download_and_extract $URL_GHOST
  cd "${WWW_PATH}/ghost" || exit
  echo -e "\nInstalling Ghost, please wait...\n"
  sudo npm install --production --unsafe-perm
  sudo npm start
  read -p "Done!. Press [Enter] to continue..."
}

while true
do
  dialog --backtitle "PiKISS" --title "[ Install Framework ]" --clear --menu  "Pick one:" 15 55 6 \
  Wordpress  "Wordpress (Latest)" \
  Node  "Node.js (You choose)" \
  Ghost  "Ghost (0.11.11)" \
  Exit   "Exit" 2>"${tempfile}"

  menuitem=$(<"${tempfile}")
  clear
  case $menuitem in
    Wordpress) wordpress ;;
    Node) nodejs ;;
    Ghost) ghost ;;
    Exit) exit ;;
  esac
done

rm $tempfile
