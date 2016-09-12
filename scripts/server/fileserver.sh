#!/bin/bash
#
# Description : Samba config
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 1.0 (13/Aug/14)
#
# HELP        · http://everyday-tech.com/samba-share-on-your-raspberry-pi/
#			  · http://raspberryparatorpes.net/proyectos/instalar-samba-preparando-un-nas-o-servidor-casero-3/
#			  · http://raspberryparatorpes.net/proyectos/optimizar-samba-preparando-un-nas-o-servidor-casero-y-4/
#			  · sudo pdbedit -L <- Show list user
#			  · sudo smbclient -L localhost <- List shares dir
#
clear

DIR_SHARE=''
VALID_USER=''
tempfile=`tempfile 2>/dev/null` || tempfile=/tmp/test$$

trap "rm -f $tempfile" 0 1 2 5 15

dialog  --title "[ Samba Config to share dir ]" \
		--yesno "Make sure you have mounted the directory you want to share before run this script. Continue?" 6 60

response=$?
case $response in
   0) 	DIR_SHARE=$(dialog --stdout --title "[ Please write down a directory to share ]" --dselect $HOME/ 14 48) ;;
   1) 	exit;;
   255) echo "[ESC] key pressed.";exit;;
esac

sudo apt install -y samba samba-common-bin

dialog  --title     "[ Samba Config to share dir ]" \
		--yes-label "Public" \
		--no-label  "User" \
		--yesno     "Choose if you want share to all(public) or restrict to a user.\n[ESC] twice to Exit." 6 70

retval=$?

case $retval in
	0)   SHARE_TYPE='public' ;;
	1)   SHARE_TYPE='user' ;;
	255) exit ;;
esac

if [ "$SHARE_TYPE" = 'user' ]; then
	dialog --inputbox "Input user:" 8 40 2>"${tempfile}"
	USER=$(<"${tempfile}")
	sudo smbpasswd -a "$USER"
	VALID_USER="valid users = ${USER} \n"
fi

dialog  --title "[ Samba Config to share dir ]" \
		--yesno "Do you want writeable permission in the shared dir?" 6 60

response=$?
case $response in
   0) 	WPERMISSION='writeable = yes \ncreate mask = 0777\ndirectory mask = 0777\n'; sudo chmod 775 "$DIR_SHARE" ;;
   1) 	WPERMISSION='writeable = no \n' ;;
   255) echo "[ESC] key pressed.";exit;;
esac

[ -f /etc/samba/smb.conf.backup ] && echo "/etc/samba/smb.conf.backup already exist." || sudo cp /etc/samba/smb.conf{,.backup}

# Changing some values to file /etc/samba/smb.conf
sudo sed -i 's/   workgroup = WORKGROUP/   workgroup = HOME/g' -i '/#### Networking ####/i\ max xmit = 65535\nsocket options = TCP_NODELAY IPTOS_LOWDELAY SO_SNDBUF=65535 SO_RCVBUF=65535\nread raw = yes\nwrite raw = yes\nmax connections = 65535\nmax open files = 65535\n' /etc/samba/smb.conf

#Dir to share
echo -e "[HOME_SHARED] \npath = ${DIR_SHARE}\ncomment = Shared directory\n ${WPERMISSION}browseable = yes\n${VALID_USER}" | sudo tee -a /etc/samba/smb.conf

#test
testparm -s

# sudo systemctl enable samba

echo -e 'Done. Wait a minute and go to another device/PC and input the next path in your files browser:\n · Windows: \\\\'"$(hostname)"'\n · Linux: smb://'"$(hostname)"
read -p 'Press [ENTER] to continue...'
