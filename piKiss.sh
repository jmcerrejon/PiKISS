#!/bin/bash
# - - - - - - - - - - - - - - - - - -
# PiKISS (Pi Keeping simple, stupid!)
# - - - - - - - - - - - - - - - - - -
#
# Author  : Jose Cerrejon Gonzalez
# Mail    : ulysess@gmail_dot_com
# Version : Beta 0.9.5 (2015)
#
# USE AT YOUR OWN RISK!
#
# - - -
# TO DO
# - - -
#
# · Add apt-get install sudo, wget unrar-free if doesn't installed.
#
# · Shell Style Guide: https://google-styleguide.googlecode.com/svn/trunk/shell.xml
#
# - - - -
# INCLUDE
# - - - -
#

. ./scripts/helper.sh || . ../helper.sh || . ./helper.sh || wget -q 'http://github.com/jmcerrejon/PiKISS/raw/master/scripts/helper.sh'
check_board || { echo "Missing file helper.sh. I've tried to download it for you. Try to run the script again." && exit 1; }

check_board
check_temperature
check_internet_available
mkDesktopEntry

#
# - - - - -
# VARIABLES
# - - - - -
#
TITLE="PiKISS (Pi Keeping It Simple, Stupid!) | Author: Jose Cerrejon | Ver: 0.9.5 (2015) | IP: $(hostname -I)"
NOW=$(date +"%Y-%m-%d")
CHK_UPDATE=0
wHEIGHT=19
wWIDTH=70
#
# - - - - -
# FUNCTIONS
# - - - - -
#
function usage()
{
	echo -e "$TITLE\n\nScript designed to config Raspberry Pi(Raspbian) or ODROID-C1(Ubuntu) easier for everyone.\n"
	echo -e "Usage: piKiss [Arguments]\n\nArguments:\n"
	echo "-h  | --help       : This help."
	echo "-nu | --no_update  : No check if repositories are updated."
	echo "-ni | --noinet     : No check if internet connection is available."
	echo " "
	echo "For trouble, ideas or technical support please visit http://misapuntesde.com"
}

function lastUpdateRepo()
{
    DATENOW=$(date +"%d-%b-%y")

    if [ -e "checkupdate.txt" ]; then
        CHECKUPDATE=$(cat checkupdate.txt)

        if [[ $CHECKUPDATE -ge $DATENOW ]]; then
            echo "Update repo: NO"
            return 0
        fi
    fi

    echo "Update repo: YES"
    (echo "$DATENOW" > checkupdate.txt)
    sudo apt-get update
}

function isMissingDialogPkg()
{
	if [ ! -f /usr/bin/dialog ]; then
		while true; do
			read -p "Missing 'dialog' package. Do you wish to let me attempt to install it for you? (aprox. 1.3 kB) [y/n] " yn
			case $yn in
				[Yy]* ) sudo apt-get install dialog -y && DIALOG=dialog;break ;;
				[Nn]* ) echo "Please install 'dialog' package to continue."; exit 1 ;;
				* ) echo "Please answer (y)es or (n)o.";;
			esac
		done
	fi
}

#
# - - - - - - -
# Initial checks
# - - - - - - -
#

# Arguments
while [ "$1" != "" ]; do
    case $1 in
        -nu | --no_update )     CHK_UPDATE=1
                                ;;
        -ni | --noinet )	NOINTERNETCHECK=1
                                ;;
        -h | --help )           usage
                                exit
                                ;;
        * )                     usage
                                exit 1
    esac
    shift
done

# Last time 'apt-get update' command was executed
#if [ ! $CHK_UPDATE = 1 ]; then
    #lastUpdateRepo
#fi

# dialog exist
isMissingDialogPkg

#
# - - - - - -
# MENU OPTIONS
# - - - - - -
#


#
# - - - -
# SUB-MENU
# - - - -
#
function smInfo(){

	cmd=(dialog --clear --backtitle "$TITLE${TEMPC}| Board: $MODEL" --title "[ Info ]" --menu "Select an option from the list:" $wHEIGHT $wWIDTH $wHEIGHT)

	if [[ ${MODEL} == 'Raspberry Pi' ]]; then
		options=(
			Back "Back to main menu"
			Chkimg "Check some distros images to know if they are updated"
			Weather "Weather info from your country"
			Bmark "Benchmark RPi (CPU, MEM, SD Card...)"
			Lynis "Lynis is a security auditing tool."
			TestInet "Test Internet bandwidth"
			WebMonitor "Web monitor to your RPi"
		)
	elif [[ ${MODEL} == 'ODROID-C1' ]]; then
		options=(
			Back "Back to main menu" \
		)
	fi

	choices=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)

	for choice in $choices
	do
	    case $choice in
			Back)		break ;;
			Chkimg) 	./scripts/info/check_lastmod_img.sh ;;
			Weather) 	./scripts/info/weather.sh ;;
			Bmark) 		./scripts/info/bmark.sh ;;
			Lynis) 		./scripts/info/lynis.sh ;;
			TestInet) 	./scripts/info/test_inet.sh ;;
			WebMonitor)	./scripts/info/web_monitor.sh ;;
	    esac
	done
}

function smTweaks(){

	cmd=(dialog --clear --backtitle "$TITLE${TEMPC}| Model: $MODEL" --title "[ Tweaks ]" --menu "Select a tweak from the list:" $wHEIGHT $wWIDTH $wHEIGHT)

	if [[ ${MODEL} == 'Raspberry Pi' ]]; then
		options=(
			Back "Back to main menu"
			Autologin "Set autologin for the pi user"
			Others "CPU performance, disable Ethernet and so on"
			Packages "Programs you don't use (maybe) to free space"
			Daemons "Disable services useless"
		)
	elif [[ ${MODEL} == 'ODROID-C1' ]]; then
		options=(
			Back "Back to main menu"
			Autologin "Set autologin as current user (CLI mode)"
			Others "CPU performance, disable Ethernet and so on"
			Daemons "Disable services useless (not permanently)"
		)
	fi

	choices=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)

	for choice in $choices
	do
	    case $choice in
			Back) 		break ;;
			Autologin) 	./scripts/tweaks/autologin.sh ;;
			Others) 	./scripts/tweaks/others.sh ;;
			Packages) 	./scripts/tweaks/removepkg.sh ;;
			Daemons) 	./scripts/tweaks/services.sh ;;
	    esac
	done
}

function smGames(){

	cmd=(dialog --clear --backtitle "$TITLE${TEMPC}| Model: $MODEL" --title "[ Games ]" --menu "Select game from the list:" $wHEIGHT $wWIDTH $wHEIGHT)

	if [[ ${MODEL} == 'Raspberry Pi' ]]; then
		options=(
			Back "Back to main menu"
			Dune2 "Dune 2 Legacy"
			Descent "Descent 1 & 2 Shareware Ed."
			RWolf "Return to Castle Wolfenstein (Demo)"
			Crispy-doom "Crispy to play Doom, Heretic, Hexen, Strife"
			Sqrxz4 "Sqrxz 4: Difficult platform game"
		)
	elif [[ ${MODEL} == 'ODROID-C1' ]]; then
		options=(
			Back "Back to main menu"
			Crispy-doom "Crispy to play Doom, Heretic, Hexen, Strife"
			Quake "Quake 2"
		)
	fi

	choices=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)

	for choice in $choices
	do
	    case $choice in
			Back) 		 break ;;
		#	Minecraft) 	 ./scripts/games/minecraft.sh ;;
			Dune2) 		 ./scripts/games/dune2.sh ;;
			Descent) 	 ./scripts/games/descent.sh ;;
			Quake) 		 ./scripts/games/quake.sh ;;
			RWolf) 		 ./scripts/games/rwolf.sh ;;
			Crispy-doom) ./scripts/games/cdoom.sh ;;
			Sqrxz4) 	 ./scripts/games/sqrxz4.sh ;;
	    esac
	done
}

function smEmulators(){
	cmd=(dialog --clear --backtitle "$TITLE${TEMPC}| Model: $MODEL" --title "[ Emulators ]" --menu "Select emulator from the list:" $wHEIGHT $wWIDTH $wHEIGHT)

	if [[ ${MODEL} == 'Raspberry Pi' ]]; then
		options=(
			Back "Back to main menu"
			Snes "SNES Emulator port based on SNES9X 1.39"
			Mame4all "port based on Franxis MAME4ALL (0.37b5)"
			Speccy "ZX-Spectrum emulator"
			Rpix86 "rpix86 MS-DOS emulator"
			8086 "8086 PC XT-compatible emulator"
			Amiga "Some Amiga emulators"
			Gba "Gameboy Advance"
			PCE-CD "PC-Engine"
			MSX "Compile or install MSX (Latest)"
			Pifba "Emulates old arcade games using CPS1, CPS2,..."
		)
	elif [[ ${MODEL} == 'ODROID-C1' ]]; then
		options=(
			Back "Back to main menu"
		)
	fi

	choices=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)

	for choice in $choices
	do
	    case $choice in
			Back) 		break ;;
			Snes) 		./scripts/emus/pisnes.sh ;;
			Mame4all) 	./scripts/emus/mame4allpi.sh ;;
			Speccy) 	./scripts/emus/speccy.sh ;;
			Amiga) 	./scripts/emus/amiga.sh ;;
			Rpix86) 	./scripts/emus/rpix86.sh ;;
			8086) 		./scripts/emus/8086tiny.sh ;;
			Gba)        ./scripts/emus/gba.sh ;;
			PCE-CD)     ./scripts/emus/pce.sh ;;
			MSX)     ./scripts/emus/msx.sh ;;
			Pifba) 		./scripts/emus/pifba.sh ;;
	    esac
	done
}


function smMultimedia(){
	cmd=(dialog --clear --backtitle "$TITLE${TEMPC}| Model: $MODEL" --title "[ Multimedia ]" --menu "Select a script from the list:" $wHEIGHT $wWIDTH $wHEIGHT)

	if [[ ${MODEL} == 'Raspberry Pi' ]]; then
		options=(
			Back "Back to main menu"
			Rplay "AirPlay Mirroring on your Pi with RPlay"
			Kiosk "Image slideshow"
		)
	elif [[ ${MODEL} == 'ODROID-C1' ]]; then
		options=(
			Back "Back to main menu"
		)
	fi

	choices=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)

	for choice in $choices
	do
	    case $choice in
			Back) 		break ;;
			Rplay)		./scripts/mmedia/airplay.sh ;;
	        Kiosk)      ./scripts/mmedia/kiosk.sh ;;
	        XBMC) 		./scripts/mmedia/xbmc.sh ;;
	    esac
	done
}

function smConfigure(){
	cmd=(dialog --clear --backtitle "$TITLE${TEMPC}| Model: $MODEL" --title "[ Configure ]" --menu "Select to configure your distro:" $wHEIGHT $wWIDTH $wHEIGHT)

	if [[ ${MODEL} == 'Raspberry Pi' ]]; then
		options=(
			Back "Back to main menu"
			RaspNet "Configure Raspbian Net Install distro"
			SSIDCfg "Configure SSID (WPA/WPA2 with PSK)"
			Joypad "Configure WII, XBox360 controller"
			Backup "Simple backup dir to run daily"
			Applekeyb "Bluetooth keyboard"
			Netcfg "Configure static IP"
		)
	elif [[ ${MODEL} == 'ODROID-C1' ]]; then
		options=(
			Back "Back to main menu"
		)
	fi

	choices=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)

	for choice in $choices
	do
	    case $choice in
			Back) 		break;;
			RaspNet)    ./scripts/config/raspnetins.sh;;
			SSIDCfg)    sudo ./scripts/config/ssidcfg.sh;;
			Joypad) 	sudo ./scripts/config/jpad.sh;;
			Backup) 	sudo ./scripts/config/backup.sh;;
			Applekeyb) 	sudo ./scripts/config/applekeyb.sh;;
			Netcfg) 	sudo ./scripts/config/netconfig.sh;;
	    esac
	done
}

function smInternet(){
	cmd=(dialog --clear --backtitle "$TITLE${TEMPC}| Model: $MODEL" --title "[ Internet ]" --menu "Select an option from the list:" $wHEIGHT $wWIDTH $wHEIGHT)

	if [[ ${MODEL} == 'Raspberry Pi' ]]; then
		options=(
			Back "Back to main menu"
			Plowshare "Direct download from hosters like uploaded,..."
			Epiphany "Web browser"
			Downmp3 "Download mp3 from GrooveShark"
		)
	elif [[ ${MODEL} == 'ODROID-C1' ]]; then
		options=(
			Back "Back to main menu"
		)
	fi

	choices=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)

	for choice in $choices
	do
	    case $choice in
			Back) 		break ;;
			Plowshare) 	./scripts/inet/ddown.sh ;;
			Epiphany)   ./scripts/inet/epiphany.sh ;;
			Downmp3) 	./scripts/inet/dwnmp3.sh ;;
	    esac
	done
}

function smServer(){
	cmd=(dialog --clear --backtitle "$TITLE${TEMPC}| Model: $MODEL" --title "[ Server ]" --menu "Select to configure your distro as a server:" $wHEIGHT $wWIDTH $wHEIGHT)

	if [[ ${MODEL} == 'Raspberry Pi' ]]; then
		options=(
			Back "Back to main menu"
			FTP "Simple FTP Server with vsftpd"
			Cups "Printer server (cups)"
			Minidlna "Install/Compile UPnP/DLNA Minidlna"
			Web "Apache+PHP5"
			Smtp "SMTP Config to send e-mail"
			WebDAV "WebDAV to share local content with Apache"
			SMB "Share files with SAMBA"
			OwnCloud "Access your data from all your devices"
			GitServer "Use your RPi like a Git Server"
			FWork "Wordpress, Node.js among others"
			DB "MySQL+PHP5 connector"
		)
	elif [[ ${MODEL} == 'ODROID-C1' ]]; then
		options=(
			Back "Back to main menu"
			FTP "Simple FTP Server with "
		)
	fi

	choices=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)

	for choice in $choices
	do
	    case $choice in
			Back) 		break ;;
	        Cups)  		./scripts/server/printer.sh ;;
	        FTP)  		./scripts/server/ftp.sh ;;
        	Minidlna)	./scripts/server/mediaserver.sh ;;
        	Web) 		./scripts/server/web.sh ;;
			Smtp) 		./scripts/server/smtp.sh ;;
        	WebDAV) 	./scripts/server/webdav.sh ;;
        	SMB) 		./scripts/server/fileserver.sh ;;
        	OwnCloud) 	sudo ./scripts/server/owncloud.sh ;;
        	GitServer) 	./scripts/server/gitserver.sh ;;
        	FWork)		./scripts/server/fwork.sh ;;
        	DB) 		./scripts/server/db.sh ;;
	    esac
	done
}

function smOthers(){
	cmd=(dialog --clear --backtitle "$TITLE${TEMPC}| Model: $MODEL" --title "[ Others ]" --menu "Another scripts uncategorized:" $wHEIGHT $wWIDTH $wHEIGHT)

	if [[ ${MODEL} == 'Raspberry Pi' ]]; then
		options=(
			Back "Back to main menu"
			NetTools "MITM Pentesting Opensource Toolkit (Require X)"
			Part "Check issues & fix SD corruptions"
			SDL2 "Compile SDL2 + Libraries (It can take 40 minutes)"
			GCC "Install GCC 4.7 on Raspberry Pi"
			WhatsApp "Send WhatsApp messages from terminal"
			Synergy "Synergy allow you to share one keyboard and mouse to computers on LAN"
			Fixes "Fix some problems with the Raspbian OS"
			Aircrack "Compile Aircrack-NG suite easily"
		)
	elif [[ ${MODEL} == 'ODROID-C1' ]]; then
		options=(
			Back "Back to main menu" \
		)
	fi

	choices=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)

	for choice in $choices
	do
	    case $choice in
			Back) 		break ;;
			NetTools) 	./scripts/others/nettools.sh ;;
			Part) 		./scripts/others/checkpart.sh ;;
			SDL2) 		./scripts/others/sdl2.sh ;;
			GCC) 		./scripts/others/gcc47.sh ;;
			WhatsApp) 	./scripts/others/whatsapp.sh ;;
			Synergy) 	./scripts/others/synergy.sh ;;
			Fixes)		./scripts/others/fixes.sh ;;
			Aircrack) 	./scripts/others/aircrack.sh ;;
	    esac
	done
}
#
# - - - - -
# MAIN MENU
# - - - - -
#
while true
do
	cmd=(dialog --clear --backtitle "$TITLE${TEMPC}| Model: $MODEL" --title	"[ M A I N - M E N U ]" --menu "You can use the UP/DOWN arrow keys, the first letter of the choice as a hot key, or the number keys 1-9 to choose an option:" $wHEIGHT $wWIDTH $wHEIGHT)

	options=(
		Tweaks "Put your distro to the limit" 
		Games "Install or compile games easily"
		Emula "Install emulators"
		Info "Info about the Pi or related"
		Multimedia "Help you to install apps like XBMC"
		Configure "Installations are piece of cake now"
		Internet "All refered to internet"
		Server "Use your distro like a server"
		Others "Scripts with others thematics"
		Exit "Exit to the shell"
	)

	choices=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)

	for choice in $choices
	do
	    case $choice in
			Tweaks)	    smTweaks ;;
			Games) 	    smGames ;;
		    Emula)	    smEmulators ;;
			Info)	    smInfo ;;
			Multimedia) smMultimedia ;;
			Configure)  smConfigure ;;
			Internet)   smInternet ;;
			Server)     smServer ;;
			Others)     smOthers ;;
			Exit) 	    echo -e "\nThanks for visiting http://misapuntesde.com" && exit ;;
			1)
	    		echo -e "\nCancel pressed." && exit;;
	  		255)
	    		echo -e "\nESC pressed." && exit;;
	    esac
	done
done
