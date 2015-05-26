#!/bin/bash
 
#
# Script to install Nagios 3 network monitoring software on new Rapsberry Pi Raspbian sinatalltion.
#  This script is not meant to be used on an already configured system. 
#  This script could overwrite or break an existing confgiuration.
#
#    By NetCodger 3/25/2015
#
#    https://netcodger.wordpress.com/2015/03/26/nagios-3-on-a-raspberry-pi-2/
 
 
 
# Make sure this script only runs on a Raspberry Pi.
if ! uname -a | grep "raspberrypi"; then
     echo "This script is meant to only run on a Raspberry Pi."
     echo "This does not appear to be a Raspberry Pi."
     read -n 1 -p "Pres any key exit"
     exit -1
fi
 
 
# Make sure that we are root
 if [ $(id -u) != 0 ]; then
     echo "Insufficient privilege to execute this script."
     echo
     echo "Please re-run the script with sudo installNagios3.sh"
     read -n 1 -p "Pres any key exit"
     exit -1
fi
 
 
 
# Are you sure?
echo "This script is for installing Nagios 3 on a new Raspberry Pi installatoin."
echo "Installing on a modified system could clobber any previous modifications."
read -p "Are you sure you want to continue? (y/n)" -n 1 -r
echo    # (optional) move to a new line
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    exit 1
fi
 
 
 
# Update installed Raspbian(Debian) software.
apt-get update
apt-get --assume-yes --force-yes upgrade
 
 
# Update Pi firmware.
rpi-update
 
 
# Prompt user to set timezone as necessary.
dpkg-reconfigure tzdata
 
 
# Install web server and PHP
apt-get --no-install-recommends --assume-yes --force-yes --fix-missing install lighttpd
 
apt-get --assume-yes --force-yes --fix-missing install php5-cgi
 
apt-get --assume-yes --force-yes --fix-missing install postfix bsd-mailx exim4-base-
 
 
# Configure lighttpd to enable PHP
if ! grep -Fxq '.php" => "/usr/bin/php5-cgi' /etc/lighttpd/conf-enabled/10-php5-cgi.conf; then
     echo ' cgi.assign += (".php" => "/usr/bin/php5-cgi")' >> /etc/lighttpd/conf-enabled/10-php5-cgi.conf
fi
 
lighttpd-enable-mod cgi auth status php5-cgi
 
 
 
# Install Nagios 3.
apt-get --assume-yes --force-yes --fix-missing install nagios3
 
#Configure lighttpd for Nagios
if ! grep -Fxq '/cgi-bin/nagios3" => "/usr/lib/cgi-bin/nagios3' /etc/lighttpd/conf-available/10-nagios3.conf; then
     echo 'alias.url =     (' >> /etc/lighttpd/conf-available/10-nagios3.conf
     echo '                "/cgi-bin/nagios3" => "/usr/lib/cgi-bin/nagios3",' >> /etc/lighttpd/conf-available/10-nagios3.conf
     echo '                "/nagios3/cgi-bin" => "/usr/lib/cgi-bin/nagios3",' >> /etc/lighttpd/conf-available/10-nagios3.conf
     echo '                "/nagios3/stylesheets" => "/etc/nagios3/stylesheets",' >> /etc/lighttpd/conf-available/10-nagios3.conf
     echo '                "/nagios3" => "/usr/share/nagios3/htdocs"' >> /etc/lighttpd/conf-available/10-nagios3.conf
     echo '                )' >> /etc/lighttpd/conf-available/10-nagios3.conf
     echo '' >> /etc/lighttpd/conf-available/10-nagios3.conf
     echo '' >> /etc/lighttpd/conf-available/10-nagios3.conf
     echo '$HTTP["url"] =~ "^/nagios3/cgi-bin" {' >> /etc/lighttpd/conf-available/10-nagios3.conf
     echo '        cgi.assign = ( "" => "" )' >> /etc/lighttpd/conf-available/10-nagios3.conf
     echo '}' >> /etc/lighttpd/conf-available/10-nagios3.conf
     echo ''  >> /etc/lighttpd/conf-available/10-nagios3.conf
     echo '$HTTP["url"] =~ "nagios" {' >> /etc/lighttpd/conf-available/10-nagios3.conf
     echo '        auth.backend = "htpasswd"' >> /etc/lighttpd/conf-available/10-nagios3.conf
     echo '        auth.backend.htpasswd.userfile = "/etc/nagios3/htpasswd.users"'  >> /etc/lighttpd/conf-available/10-nagios3.conf
     echo '        auth.require = ( "" => (' >> /etc/lighttpd/conf-available/10-nagios3.conf
     echo '                "method" => "basic",' >> /etc/lighttpd/conf-available/10-nagios3.conf
     echo '                "realm" => "nagios",' >> /etc/lighttpd/conf-available/10-nagios3.conf
     echo '                "require" => "user=nagiosadmin"' >> /etc/lighttpd/conf-available/10-nagios3.conf
     echo '                )' >> /etc/lighttpd/conf-available/10-nagios3.conf
     echo '        )' >> /etc/lighttpd/conf-available/10-nagios3.conf
     echo '        setenv.add-environment = ( "REMOTE_USER" => "user" )' >> /etc/lighttpd/conf-available/10-nagios3.conf
     echo '}' >> /etc/lighttpd/conf-available/10-nagios3.conf
fi
 
lighttpd-enable-mod nagios3
 
 
# Optional install Nuvola skin.
wget "https://exchange.icinga.org/exchange/Nuvola+Style/files/145/nagios-nuvola-1.0.3.tar.gz"
mkdir nuvola
cd nuvola
tar -xzvf ../nagios-nuvola-1.0.3.tar.gz
cp -a html/* /usr/share/nagios3/htdocs/
cp -a html/stylesheets/* /etc/nagios3/stylesheets/.
cd ..
rm nagios-nuvola-1.0.3.tar.gz
rm -rf nuvola/
 
 
# Configure Nuvola
sed -i -r 's#/nagios/#/nagios3/#' /usr/share/nagios3/htdocs/config.js
mv /usr/share/nagios3/htdocs/side.html /usr/share/nagios3/htdocs/side.php
 
# Create the Nagiosadmin user and set a password.
htpasswd -cb /etc/nagios3/htpasswd.users nagiosadmin nagios
 
 
# Reboot and begin configuration of Nagios.
echo
echo "----------------------------------"
echo "Reboot Raspberry Pi and begin using Nagios?"
echo "See Nagios manual about configuring Nagios."
read -p "Press y to reboot and n to exit" -n 1 -r
echo    # (optional) move to a new line
if [[ $REPLY =~ ^[Yy]$ ]]; then
    reboot
fi