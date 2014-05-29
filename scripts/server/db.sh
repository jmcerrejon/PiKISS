#!/bin/bash
#
# Description : Install and optimize databases
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 0.4 (29/May/14)
#
# TODO        · New DB like MariaDB, MongoDB,...
#             · Modify query_cache_size value
#
clear

# MySQL
echo -e "Installing MySQL+PHP5 conn..."
sudo apt-get install -y mysql-server php5-mysql mysql-client
echo -e "Optimizing..."
sudo mv /etc/mysql/my.cnf /etc/mysql/my.cnf.bak
sudo cp /usr/share/doc/mysql-server-5.5/examples/my-small.cnf /etc/mysql/my.cnf
# query_cache_size = 8M
sudo service mysql restart
read -p "Done!. Press [Enter] to continue..."