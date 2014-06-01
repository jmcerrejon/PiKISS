#!/bin/bash
#
# Description : Install Web Server + php
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 0.7.1 (26/May/14)
#
# TODO        · Select another web server: nginx, cherokkee, lighhttpd
#
clear

tempfile=`tempfile 2>/dev/null` || tempfile=/tmp/test$$

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

while true
do
	dialog --backtitle "PiKISS" \
		--title 	"[ Install Web Server ]" --clear \
		--menu  	"Pick one:" 15 55 5 \
        	Apache  	"Apache" \
            	Monkey       	"Monkey HTTP" \
            	Exit        	"Exit" 2>"${tempfile}"

	menuitem=$(<"${tempfile}")

	case $menuitem in
        	Apache) apache ;;
        	Monkey) monkey;;
        	Exit) exit;;
	esac
done
