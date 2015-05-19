#!/bin/bash
#
# Description : Send WhatsApp message from terminal thks to https://github.com/tgalal/yowsup
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 0.9 (13/Jan/14)
#
# TODO        · Test register_number() method
clear

YOUSUP_CLI="$HOME/sc/yowsup/src/yowsup-cli"

whatsapp_test(){
    echo "Enter phone number to send a message (receiver) (Ex. 34555957618): "
    read PHONE_RECEIVER
    echo "Enter Message: "
    read PHONE_MSG
    
    echo "Press CTRL+Z if Auth failed and check if the number is registered on WhatsApp network or the config.example file is ok inside $HOME/sc/yowsup/src/"
    $YOUSUP_CLI -c config.example -s $PHONE_RECEIVER "$PHONE_MSG"
}

register_number(){
    $YOUSUP_CLI -c config.example --requestcode sms
    echo "Enter Register Code (xxx-xxx): "
    read REG_CODE
    $YOUSUP_CLI -c config.example --register $REG_CODE
    whatsapp_test
}

whatsapp(){
    if [[ ! -d $HOME/sc/yowsup && ! /usr/local/bin/yowsup-cl ]] ; then 
        echo -e "Grab a coffee ;)..."
        mkdir -p $HOME/sc && cd $_
        sudo apt-get install -y python-dateutil python-pip python-dev ncurses-dev
        git clone git://github.com/tgalal/yowsup.git
        chmod +x yowsup-cli
        pip install yowsup2
        python setup.py install
    fi

    if [[ ! -f $HOME/sc/yowsup/src/config.example.bak ]] ; then
        echo "Enter country code (Ex. Spain=34): "
        read CC
        echo "Enter cc+phone number (Ex. 34555845912): "
        read PHONE
        echo "Enter password: "
        read PSWD

        CONFIG="
            cc=$CC\n
            phone=$PHONE\n
            id=\n
            password=$PSWD\n
        "
        cp $HOME/sc/yowsup/src/config.example $HOME/sc/yowsup/src/config.example.bak
        echo -e $CONFIG > config.example
    fi

    read -p "Do you have the phone number registered on Whatsapp? (y/n): " option
    case "$option" in
        y*) whatsapp_test ;;
        n*) register_number ;;
    esac
}

echo -e "\nWhatsApp from Terminal\n======================\n"
read -p "Continue? (y/n): " option
case "$option" in
    y*) whatsapp ;;
esac