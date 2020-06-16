#!/bin/bash
#
# Description : Install Webdav for Apache
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 0.7 (14/May/14)
#
# Thks to     : https://www.alvaroreig.com/como-configurar-unservidor-webdav-en-la-raspberry-pi/
#               https://www.instructables.com/id/Apache-SSL-WebDav-Server/?ALLSTEPS
#
# TODO        : Webdav to other web server
#               With SSL certificate
#
clear

VHOST_NAME="server"
IP=$(hostname -I)

vhost_ssl(){
    echo -e "\nGenerating file...\n"

    FILE="
    <VirtualHost *:443>\n
      ServerName $VHOST_NAME\n
      ErrorLog /var/log/apache2/$VHOST_NAME_error.log\n
     \n
      SSLEngine on\n
      SSLCertificateFile /etc/ssl/cfdos/server.crt\n
      SSLCertificateKeyFile /etc/ssl/cfdos/server.key\n
     \n
      DocumentRoot /var/www/webdav\n
     \n
      <Location />\n
        order deny,allow\n
        #Allow from 192.168.1.1/255.255.255.0 #allow access from LAN\n
        #Allow from 192.168.1.8/255.255.255.255 #allow access from IP 8\n
        order allow,deny\n
        Allow from all\n
        Deny from all\n
     \n
        DAV On\n
        AuthType Basic\n
        AuthName 'webdav'\n
        AuthUserFile /var/www/passwd.dav\n
        Require valid-user\n
      </Location>\n
    </VirtualHost>\n
    "

    echo -e $FILE | sudo tee -a /etc/apache2/sites-available/$VHOST_NAME
}

vhost(){
    echo -e "\nGenerating file...\n"

    FILE="
    NameVirtualHost *\n
    <VirtualHost *>\n
            ServerAdmin webmaster@localhost\n
    \n
            DocumentRoot /var/www/webdav/\n
            <Directory /var/www/webdav/>\n
                    Options Indexes MultiViews\n
                    AllowOverride None\n
                    Order allow,deny\n
                    allow from all\n
            </Directory>\n
    \n
            Alias /webdav /var/www/webdav\n
    \n
            <Location /webdav>\n
               DAV On\n
               AuthType Basic\n
               AuthName 'webdav'\n
               AuthUserFile /var/www/webdav/passwd.dav\n
               Require valid-user\n
           </Location>\n
    \n
    </VirtualHost>\n
    "

    echo -e $FILE | sudo tee -a /etc/apache2/sites-available/default
}

webdav_ssl(){
    sudo mkdir -p /etc/ssl/cfdos
    sudo openssl req -config /etc/ssl/openssl.cnf -new -out /etc/ssl/cfdos/server.csr
    sudo openssl rsa -in privkey.pem -out /etc/ssl/cfdos/server.key
    sudo openssl x509 -in /etc/ssl/cfdos/server.csr -out /etc/ssl/cfdos/server.crt -req -signkey /etc/ssl/cfdos/server.key -days 3650
    rm privkey.pem

    echo -e "\nEnter directory full path you want to share:"
    read WEBDAV_DIR

    sudo ln -s $WEBDAV_DIR /var/www/webdav
    sudo chown www-data:www-data /var/www/webdav

    echo -e "\nPlease enter a new user to Webdav:"
    read WEBDAV_USER

    htpasswd -c /var/www/passwd.dav $WEBDAV_USER
    sudo chown root:www-data /var/www/passwd.dav
    sudo chmod 440 /var/www/passwd.dav

    sudo a2enmod dav_fs
    sudo a2enmod dav
    sudo a2enmod ssl
    sudo a2enmod auth_digest

    echo -e "\nPlease enter a virtualhost name:"
    read $VHOST_NAME

    vhost_ssl

    #sudo sed -i '0,/RE/s/.*NameVirtualHost.*/&\nNameVirtualHost *:443/' /etc/apache2/ports.conf

    sudo a2ensite $VHOST_NAME
    service apache2 restart

    read -p "Done!. Now you can enter https://$IP/$VHOST_NAME and check if works. TIP: Change the location as root of /var/www/passwd.dav and modify /etc/apache2/sites-availaible/$VHOST_NAME. Press [ENTER]..."
}

echo -e "Installing Webdav for Apache\n============================\n\n· Allow you to share a directory from Apache with/outh SSL certification.\n· TIP: When ask PEM pass phrase, type a password (4-10 characters).\n       Make sure you know the path directory you want to share.\n"
read -p "Press [ENTER] to continue..."

    sudo a2enmod dav_fs
    sudo a2enmod auth_digest

    echo -e "\nEnter directory full path you want to share:"
    read WEBDAV_DIR

    sudo ln -s $WEBDAV_DIR /var/www/webdav
    sudo chown www-data:www-data /var/www/webdav
    
    echo -e "\nPlease enter a new user to Webdav:"
    read WEBDAV_USER

    htpasswd -c /var/www/passwd.dav $WEBDAV_USER
    sudo chown root:www-data /var/www/passwd.dav
    sudo chmod 440 /var/www/passwd.dav
    
    vhost
    
    sudo /etc/init.d/apache2 reload
    
    read -p "Done!. Now you can enter https://$IP/webdav and check if works. Press [ENTER] to continue..."