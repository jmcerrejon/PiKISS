#!/bin/bash
#
# Description : Automatize Download .torrent files with Flexget
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 0.3 (13/Aug/14)
#
# HELP		  · http://torrated.eu/
# 			  · http://informaticamateur.blogspot.com.es/2014/05/descargas-automaticas-de-series-con.html
#			  · Commands: flexget series list, flexget series begin "Game of Thrones" S04E08, flexget series forget "Game of Thrones" S04E08
#
# IMPROVEMENT · Send email with new episodes downloading: http://torrated2013.wordpress.com/2014/06/30/recibir-un-email-cuando-se-anada-una-descarga/
#
clear

# Install dependences
sudo apt-get install -y python python-setuptools transmission
sudo easy_install flexget mechanize transmissionrpc
clear

flexget -V

mkdir $HOME/.flexget

# Copy config.yml to 

# Modify config.yml:
# · Add download folder
# · Add user and password from $HOME/.config/transmission/settings.json

# Check if config is OK
flexget check

# flexget --test -v execute
