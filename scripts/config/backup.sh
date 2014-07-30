#!/bin/bash
#
# Description : Let user to choose a dir and program a backup with cron as normal user
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 1.0 (30/Jul/14)
#
# IMPROVEMENT · Let user to choose run the script as root
# 			  · Choose run the script daily, weekly, monthly...
#
clear

DIR_BACKUP=$(dialog --stdout --title "[ Please write down a directory to backup ]" --dselect $HOME/ 14 48) 

DIR_DESTINY=$(dialog --stdout --title "[ Now choose directory to copy backups files ]" --dselect $HOME/ 14 48)

CRON='tar cfz '${DIR_DESTINY}'backup_$(date +"%Y%d%m").tar '${DIR_BACKUP}

(crontab -l ; echo "0 0 * * * ${CRON}") | crontab -

clear
read -p "Done!. Now you have programmed a backup for $DIR_BACKUP every day to 00:00 hours. Press [Enter] to Exit."