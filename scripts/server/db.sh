#!/usr/bin/env bash
#
# Description : Install databases
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 0.5 (29/Apr/20)
#
# TODO        · Modify query_cache_size value
#
clear
sudo apt update

# MySQL

mysql() {
	echo -e "Installing MySQL+PHP5 conn..."
	sudo apt-get install -y mysql-server php7-mysql mysql-client
	echo -e "Optimizing..."
	sudo mv /etc/mysql/my.cnf /etc/mysql/my.cnf.bak
	sudo cp /usr/share/doc/mysql-server-5.5/examples/my-small.cnf /etc/mysql/my.cnf
	# query_cache_size = 8M
	sudo service mysql restart
	read -p "Done!. Press [Enter] to continue..."
}

# PostgreSQL 11

postgresql() {
	echo -e "Installing PostgreSQL..."
	sudo apt install -y postgresql libpq-dev postgresql-client postgresql-client-common
	read -p "Do you want to uninstall PostGIS extension (y/n)?: " option
		case "$option" in
			y*) install_postGIS ;;
			n*) return ;;
		esac
	# Allow remote connections
	if [ -e "/etc/postgresql/11/main/pg_hba.conf" ]; then
		sudo sh -c "echo 'host all all 0.0.0.0/0 md5' >> /etc/postgresql/11/main/pg_hba.conf"
		sudo sh -c "echo \"listen_addresses = '*'\" >> /etc/postgresql/11/main/postgresql.conf"
	fi
	sudo service postgresql restart
	sudo service postgresql status
	pg_lsclusters
	psql -c "SELECT version();"
}

install_postGIS() {
	echo -e "Installing PostGIS..."
	sudo apt install -y postgis postgresql-11-postgis-2.5
}

postgresql_add_user_manually() {
	clear
	echo -e "Type a password for new role twice. Answer the next:\nShall the new role be a superuser? (y/n) n\nShall the new role be allowed to create databases? (y/n) y\nShall the new role be allowed to create more new roles? (y/n) y\n"
	hostname=$(hostname -I) && echo -e "\nNow connect from remote with the next credentials:\n\nhostname: ${hostname}| Port: 5432 | user: pi | password: *** (password you input previously).\n"
	sudo su postgres -c "createuser pi -P --interactive && exit"
}

remove_postgresql() {
	sudo systemctl stop postgresql@11-main
	sudo apt remove -y postgresql-contrib libpq-dev postgresql-client postgresql-client-common
	sudo rm -rf /etc/postgresql
}