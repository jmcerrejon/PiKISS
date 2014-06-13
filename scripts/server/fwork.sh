#!/bin/bash
#
# Description : Install a Framework,CMS to the web server
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 0.3 (12/Jun/14)
#
# Help        · Wordpress: https://github.com/raspberrypi/documentation/blob/master/usage/wordpress.md
#             ·     Ghost: http://geekytheory.com/ghost-blog-en-raspberry-pi/
#             ·   PyPlate: http://pplware.sapo.pt/linux/dica-como-ter-o-seu-proprio-site-no-raspberry-pi/
#
clear

wordpress(){
    cd /var/www
    sudo chown $USER: .
    wget https://wordpress.org/latest.tar.gz
    tar xzf latest.tar.gz
    rm latest.tar.gz
    echo "Installed on /wordpress folder"
}

nodejs(){
    sudo su -
    cd /opt
    wget http://nodejs.org/dist/v0.10.25/node-v0.10.25-linux-arm-pi.tar.gz
    tar xvzf node-v0.10.25-linux-arm-pi.tar.gz
    ln -s node-v0.10.25-linux-arm-pi node
    chmod a+rw /opt/node/lib/node_modules
    chmod a+rw /opt/node/bin
    echo 'PATH=$PATH:/opt/node/bin' > /etc/profile.d/node.sh
    npm install -g node-gyp
    rm node-v0.10.25-linux-arm-pi.tar.gz
    echo "Press [Control+D] to return as normal user..."
    node --version
}

#read -p "Wordpress (latest)? (y/n)" option
#case "$option" in
#    y*) wordpress ;;
#esac

read -p "Node.js (0.10.25)? (y/n)" option
case "$option" in
    y*) nodejs ;;
esac