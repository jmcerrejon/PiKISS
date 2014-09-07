#!/bin/bash
#
# Description : Config smtp to send emails
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 1.0 (3/Jul/14)
#
# Help        · http://rpi.tnet.com/project/faqs/smtp
#
clear

declare -a VALUES=(
  "@gmail.com"
  "password"
  "smtp.gmail.com:587"
)
SMTP_CONF="/etc/ssmtp/ssmtp.conf"

#sudo apt-get install -y ssmtp mailutils mpack

exec 3>&1

FORM=$(dialog --title         "[ SMTP Config to send e-mail ]" \
              --form          "Please fill the next info:\n" 9 45 0 \
              "User:"         1 1 "${VALUES[0]}" 1 15 25 0 \
              "Password:"     2 1 "${VALUES[1]}" 2 15 25 0 \
              "SMTP Server:"  3 1 "${VALUES[2]}" 3 15 25 0 2>&1 1>&3)

# close fd
exec 3>&-

VALUES=(${FORM// / })

if [ ! -e $SMTP_CONF.bak ]; then
    sudo cp $SMTP_CONF{,.bak}
fi

FILE="\n
root=postmaster\n
hostname=$(hostname)\n
AuthUser=${VALUES[0]}\n
AuthPass=${VALUES[1]}\n
mailhub=${VALUES[2]}\n
FromLineOverride=YES\n
UseSTARTTLS=YES\n
"

#echo -e $FILE | sudo tee -a $SMTP_CONF
sudo sh -c "echo \"${FILE}\" > ${SMTP_CONF}"

dialog --title "[ ${SMTP_CONF} ]" --textbox ${SMTP_CONF} 40 80

echo -e "\nDone!\n· File Backup on $SMTP_CONF.bak\n· To send mail: echo \"sample text\" | mail -s \"Subject\" username@domain.com\n· With attachments: mpack -s \"test\" /home/pi/test/somefile.ext username@domain.com"
