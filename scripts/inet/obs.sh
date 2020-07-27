#!/bin/bash
#
# Description : OBS
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 1.0.0 (27/Jul/20)
# Compatible  : Raspberry Pi 4 (tested)
#
# HELP		  : https://obsproject.com/forum/threads/obs-raspberry-pi-build-instructions.115739/post-471062
# 			  : https://obsproject.com/forum/attachments/installobs-sh-txt.58920/
#
. ../helper.sh || . ./scripts/helper.sh || . ./helper.sh || wget -q 'https://github.com/jmcerrejon/PiKISS/raw/master/scripts/helper.sh'
clear
check_board || { echo "Missing file helper.sh. I've tried to download it for you. Try to run the script again." && exit 1; }

INSTALL_DIR="$HOME/apps/obs"

runme() {
	if [ ! -f "$INSTALL_DIR"/obs_start.sh ]; then
		echo -e "\nFile does not exist.\n· Something is wrong.\n· Try to install again."
		exit_message
	fi
	read -p "Press [ENTER] to run OBS..."
	"$INSTALL_DIR"/obs_start.sh
	exit_message
}

generate_icon() {
	echo -e "\nRemoving uncompatible icon..."
	sudo rm -f /usr/share/applications/com.obsproject.Studio.desktop
	echo -e "\nGenerating icon..."
	if [[ ! -e ~/.local/share/applications/obs.desktop ]]; then
		cat <<EOF >~/.local/share/applications/obs.desktop
[Desktop Entry]
Version=1.0
Name=OBS Studio
GenericName=Streaming/Recording Software
Comment=Free and Open Source Streaming/Recording Software
Exec=${HOME}/apps/obs/obs_start.sh
Icon=${HOME}/apps/obs/icon_obs.png
Terminal=false
Type=Application
Categories=AudioVideo;Recorder;
StartupNotify=true
StartupWMClass=obs
EOF
	fi
}

install() {
	clear
	# curl -sSL https://obsproject.com/forum/attachments/installobs-sh-txt.58920 | bash
}

post_install() {
	echo -e "\nPost install process. Just a moment...\n"
	mkdir -p "$INSTALL_DIR"
	cat <<EOF >"$INSTALL_DIR"/obs_start.sh
#!/bin/bash
MESA_GL_VERSION_OVERRIDE=3.3 obs
EOF
	chmod +x "$INSTALL_DIR"/obs_start.sh
	wget -q https://raw.githubusercontent.com/jmcerrejon/PiKISS/master/res/icon_obs.png -O "$INSTALL_DIR"/icon_obs.png
	generate_icon
	echo -e "\nCleaning da house...\n"
	sudo rm -rf "$HOME"/obs-build/ /tmp/ndisdk /tmp/libndi-install.sh
	echo -e "Done!. Go to Menu > Sound & Video > OBS Studio or type $INSTALL_DIR/obs_start.sh."
	runme
}

echo "Compile latest Open Broadcaster Software for Raspberry Pi"
echo "========================================================="
echo
echo " · Tested on Raspberry Pi 4 - 4 Gb"
echo " · Estimated Time on Raspberry Pi 4 (not overclocked): ~14 minutes"
echo " · This app can't be uninstalled by PiKISS if you decide to run this script. Use on your own risk."
echo " · BONUS install: NDI, OBS NDI, OBS Websockets."
echo " · Main script thanks to venepe from https://obsproject.com/forum"
echo " · NOTE: Ignore the first run with GPU issue."
echo
read -p "Continue (Y/n)? " response
if [[ $response =~ [Nn] ]]; then
	exit 0
fi

#install
post_install
