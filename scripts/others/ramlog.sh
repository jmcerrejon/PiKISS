#!/bin/bash
#
# Description : Limit SD Card writes on Rasberry Pi using Ramlog
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 1.0 (21/Apr/15)
# Compatible  : Raspberry Pi 1 & 2 (OK)
#
# HELP        : https://www.vdsar.net/limit-sd-card-writes-rasberry-pi-using-ramlog/
#
clear

ramlog_uninstall(){
	sudo dpkg -P ramlog
	sudo apt-get clean
	sudo sed -i '/# X-Start-Before: rsyslog/# Provides: ramlogi\' /etc/init.d/ramlog
	sudo sed -i '/# X-Stop-After: rsyslog/i\# Provides: ramlog' /etc/init.d/ramlog
	sudo sed -i 's/# Required-Start:    $remote_fs $time ramlog/# Required-Start:    $remote_fs $time/ig' /etc/init.d/rsyslog
	sudo sed -i 's/# Required-Stop:     umountnfs $time ramlog/# Required-Stop:     umountnfs $time/ig' /etc/init.d/rsyslog
}

fix_ramlog(){
	if [[ ! $(/etc/init.d/ramlog status | grep 'stopped') ]]; then
		update-rc.d -f rsyslog remove
		echo "Please reboot and type ' sudo update-rc.d rsyslog defaults' later"
		exit
	fi
}

if [[ ! $(apt-cache policy ramlog | grep 'Unable') ]]; then
	update-rc.d -f rsyslog remove

	sudo apt-get install -y rsync lsof
	wget -P $HOME https://www.tremende.com/ramlog/download/ramlog_2.0.0_all.deb
	sudo dpkg -i $HOME/ramlog_2.0.0_all.deb && rm $HOME/ramlog_2.0.0_all.deb

	#Check if rsyslog exist before modify the next lines
		sudo sed -i '/# Provides: ramlog/i\# X-Start-Before: rsyslog' /etc/init.d/ramlog
		sudo sed -i '/# Provides: ramlog/i\# X-Stop-After: rsyslog' /etc/init.d/ramlog

	#Check if rsyslog exist before modify the next lines
		sudo sed -i 's/# Required-Start:    $remote_fs $time/# Required-Start:    $remote_fs $time ramlog/ig' /etc/init.d/rsyslog
		sudo sed -i 's/# Required-Stop:     umountnfs $time/# Required-Stop:     umountnfs $time ramlog/ig' /etc/init.d/rsyslog

	sudo insserv
	sudo update-rc.d rsyslog defaults
else
	read -p "Already installed!. Do you want to fix it (in case does not work properly) or uninstall? [f/u]" option
case "$option" in
    f*) fix_ramlog ;;
    u*) ramlog_uninstall ;;
    e*) exit ;;
esac

fi

read -p "You must reboot twice to take effects. Do you want to reboot the first time NOW? [y/n]" option
case "$option" in
    y*) clear ; echo -e "When the OS has booted, please type 'sudo reboot' and you are done...\nRebooting, please wait" && sleep 7 $$ sudo reboot ;;
esac
