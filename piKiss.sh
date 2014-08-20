#!/bin/bash
# - - - - - - - - - - - - - - - - - -
# PiKISS (Pi Keeping simple, stupid!)
# - - - - - - - - - - - - - - - - - -
#
# Author  : Jose Cerrejon Gonzalez
# Mail    : ulysess@gmail_dot_com
# Version : Beta 0.8.6 (2014)
#
# USE AT YOUR OWN RISK!
#
# - - -
# TO DO
# - - -
# 
# · Add apt-get install sudo, wget unrar-free if doesn't installed.
# 
# - - - - -
# VARIABLES
# - - - - -
#
TITLE="PiKISS (Pi Keeping It Simple, Stupid!) .:. Jose Cerrejon .:. (ver. 0.8.6 - 2014)"
NOW=$(date +"%Y-%m-%d")
CHK_UPDATE=0
NOGUI=0
wHEIGHT=15
wWIDTH=70
INPUT=/tmp/menu.sh.$$
OUTPUT=/tmp/output.sh.$$

# trap and delete temp files
trap 'rm $OUTPUT; rm $INPUT; exit' SIGHUP SIGINT SIGTERM

#
# - - - - -
# FUNCTIONS
# - - - - -
#

function usage(){
	echo -e "$TITLE\n\nScript designed to config Raspbian and Debian derivates easier for everyone.\n\n"
	echo -e "Usage: piKiss [Arguments]\n\nArguments:\n\n"
	echo "-h  | --help       : This help."
	echo "-nu | --no_update  : No check if repositories are updated."
	echo "-ng | --nogui      : Force to use the script on the console with dialog."
	echo "-ni | --noinet     : No check if internet connection is available."
	echo " "
	echo "For trouble, ideas or technical support please visit http://misapuntesde.com"
}

# Best method and remove gdialog
# which dialog &> /dev/null
# [ $? -ne 0 ]  && echo "Dialog utility is not available, Install it"

function isMissingDialogPkg(){
	if [ -e "/tmp/.X0-lock" -a -f "/usr/bin/gdialog" -a $NOGUI = 0 ];then
		DIALOG=gdialog
	elif test -f "/usr/bin/dialog";then
		DIALOG=dialog
	else
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

function lastUpdateRepo(){
    DATENOW=$(date +"%d-%b-%y")

    if [ -e "checkupdate.txt" ];then
        CHECKUPDATE=$(cat checkupdate.txt)

        if [[ $CHECKUPDATE -ge $DATENOW ]];then
            echo "Update repo: NO"
            return 0
        fi
    fi

    echo "Update repo: YES"
    (echo "$DATENOW" > checkupdate.txt)
    sudo apt-get update
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
        -ng | --nogui )    	NOGUI=1
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


# Make sure we have internet conection
if [ ! "$NOINTERNETCHECK" = 1 ]; then
	PINGOUTPUT=$(ping -c 1 8.8.8.8 > /dev/null && echo 'true')
	if [ ! "$PINGOUTPUT" = true ]; then
		echo "Internet connection required. Check your network."; exit 1
	fi
fi

# Last time 'apt-get update' command was executed
if [ ! $CHK_UPDATE = 1 ];then
    lastUpdateRepo
fi

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
	while true
	do
		$DIALOG --clear   \
			--backtitle "$TITLE" \
			--title 	"[ Info ]" \
			--menu  	"Select an option from the list" $wHEIGHT $wWIDTH 4 \
			Back  		"Back to main menu" \
        		Chkimg  	"Check some distros images to know if they are updated" \
        	    	Weather		"Weather info from your country" \
            		Bmark       	"Benchmark your RPi with nbench" \
			WebMonitor	"Web monitor to your RPi" \
        		Cpuinfo    	"Show CPU temperature (Celsius)" 2>"${INPUT}"

		menuitem=$(<"${INPUT}")

		case $menuitem in
			Back)		break ;;
	        	Chkimg) 	./scripts/info/check_lastmod_img.sh ;;
	            	Weather)	./scripts/info/weather.sh ;;
	            	Bmark) 		./scripts/info/bmark.sh ;;
			WebMonitor)	./scripts/info/web_monitor.sh ;;
	        	Cpuinfo)	./scripts/info/cputemp.sh ;;
		esac
	done
}

function smTweaks(){
	while true
	do
		$DIALOG --clear   \
			--backtitle 	"$TITLE" \
			--title 	"[ Tweaks ]" \
			--menu  	"Select a tweak from the list" $wHEIGHT $wWIDTH 4 \
			Back  		"Back to main menu" \
	        	Autologin   	"Set autologin for Raspbian" \
	        	Others  	"CPU performance, disable Ethernet and so on" \
	        	Packages  	"Programs you don't use (maybe) to free space" \
	        	Daemons  	"Disable services useless" 2>"${INPUT}"

		menuitem=$(<"${INPUT}")

		case $menuitem in
	    		Back) 		break ;;
	            	Autologin) 	./scripts/tweaks/autologin.sh ;;
	            	Others) 	./scripts/tweaks/others.sh ;;
	        	Packages) 	./scripts/tweaks/removepkg.sh ;;
	            	Daemons) 	./scripts/tweaks/services.sh ;;
		esac
	done
}

function smGames(){
	while true
	do
		$DIALOG --clear   \
			--backtitle 	"$TITLE" \
			--title 	"[ Games ]" \
			--menu  	"Select game from the list:" $wHEIGHT $wWIDTH 4 \
			Back  		"Back to main menu" \
	        	Minecraft   	"Minecraft Pi Ed." \
	        	Dune2  		"Dune 2 Legacy" \
	        	Quake  		"Quake 2 for now" \
	        	RWolf  		"Return to Castle Wolfenstein (Demo)" \
	                Crispy-doom 	"Crispy to play Doom, Heretic, Hexen, Strife" \
			Sqrxz4		"Sqrxz 4: Difficult platform game" 2>"${INPUT}"

		menuitem=$(<"${INPUT}")

		case $menuitem in
	        	Back) 		break ;;
	        	Minecraft) 	./scripts/games/minecraft.sh ;;
	        	Dune2) 		./scripts/games/dune2.sh ;;
	        	Quake) 		./scripts/games/quake.sh ;;
        	        RWolf) 		./scripts/games/rwolf.sh ;;
                	Crispy-doom)	./scripts/games/cdoom.sh ;;
			Sqrxz4) 	./scripts/games/sqrxz4.sh ;;
		esac
	done
}

function smEmulators(){
while true
do
	$DIALOG --clear   \
		--backtitle "$TITLE" \
		--title 	"[ Emulators ]" \
		--menu  	"Select emulator from the list" $wHEIGHT $wWIDTH 4 \
		Back  		"Back to main menu" \
		Snes		"SNES Emulator port based on SNES9X 1.39" \
        	Mame4all	"port based on Franxis MAME4ALL (0.37b5)" \
        	Speccy  	"ZX-Spectrum emulator" \
        	Rpix86  	"rpix86 MS-DOS emulator" \
					8086  		"8086 PC XT-compatible emulator" \
        	Amiga  	"Some Amiga emulators" \
            Gba         "Gameboy Advance" \
            PCE-CD      "PC-Engine" \
		Pifba		"Emulates old arcade games using CPS1, CPS2,..." 2>"${INPUT}"

	menuitem=$(<"${INPUT}")

	case $menuitem in
        	Back) 		break ;;
		Snes) 		./scripts/emus/pisnes.sh ;;
        	Mame4all) 	./scripts/emus/mame4allpi.sh ;;
        	Speccy) 	./scripts/emus/speccy.sh ;;
	       	Amiga) 	./scripts/emus/amiga.sh ;;
        	Rpix86) 	./scripts/emus/rpix86.sh ;;
					8086) 		./scripts/emus/8086tiny.sh ;;
            Gba)        ./scripts/emus/gba.sh ;;
            PCE-CD)     ./scripts/emus/pce.sh ;;
		Pifba) 		./scripts/emus/pifba.sh ;;
	esac
done
}


function smMultimedia(){
while true
do
	$DIALOG --clear   \
		--backtitle	"$TITLE" \
		--title 	"[ Multimedia ]" \
		--menu  	"Select app from the list" $wHEIGHT $wWIDTH 4 \
		Back  		"Back to main menu" \
        		TVPlayer		"Play Spanish TV Channel" \
		Rplay		"AirPlay to do mirroring" \
        	Kiosk		"Image slideshow" \
		XBMC		"Install XBMC" 2>"${INPUT}"

	menuitem=$(<"${INPUT}")

	case $menuitem in
		Back) 		break ;;
        TVPlayer)   ./scripts/mmedia/tvplayer.sh ;;
		Rplay)		./scripts/mmedia/airplay.sh ;;
        Kiosk)      ./scripts/mmedia/kiosk.sh ;;
        XBMC) 		./scripts/mmedia/xbmc.sh ;;
	esac
done
}

function smConfigure(){
while true
do
	$DIALOG --clear   \
		--backtitle 	"$TITLE" \
		--title 	"[ Configure ]" \
		--menu  	"Select to configure your distro" $wHEIGHT $wWIDTH 4 \
		Back  		"Back to main menu" \
            RaspNet      	"Configure Raspbian Net Install distro" \
            SSIDCfg      	"Configure SSID (WPA/WPA2 with PSK)" \
        	Joypad      	"Configure WII, XBox360 controller" \
        	Backup      	"Simple backup dir to run daily" \
        	Applekeyb      	"Bluetooth keyboard" \
		Netcfg		"Config static IP address" 2>"${INPUT}"

	menuitem=$(<"${INPUT}")

	case $menuitem in
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
while true
do

	$DIALOG --clear   \
		--backtitle "$TITLE" \
		--title 	"[ Internet ]" \
		--menu  	"Select an option from the list" $wHEIGHT $wWIDTH 4 \
		Back  		"Back to main menu" \
        	Plowshare  	"Direct download from hosters like uploaded,..." \
            Epiphany    "Web browser" \
		Downmp3		"Download mp3 from GrooveShark" 2>"${INPUT}"

	menuitem=$(<"${INPUT}")

	case $menuitem in
    		Back) 		break ;;
           	Plowshare) 	./scripts/inet/ddown.sh ;;
            Epiphany)   ./scripts/inet/epiphany.sh ;;
		Downmp3) 	./scripts/inet/dwnmp3.sh ;;

	esac
done
}

function smServer(){
while true
do

	$DIALOG --clear   \
		--backtitle 	"$TITLE" \
		--title 	"[ Server ]" \
		--menu  	"Select to configure your distro as a server" $wHEIGHT $wWIDTH 4 \
		Back  		"Back to main menu" \
	        Cups	        "Printer server (cups)" \
	        Minidlna        "Install/Compile UPnP/DLNA Minidlna" \
		Web		"Apache+PHP5" \
		Smtp		"SMTP Config to send e-mail" \
        	WebDAV      	"WebDAV to share local content with Apache" \
        	SMB      	"Share files with SAMBA" \
        	OwnCloud      	"Access your data from all your devices" \
            	FWork      	"Wordpress, Node.js among others" \
        	DB      	"MySQL+PHP5 connector" 2>"${INPUT}"

	menuitem=$(<"${INPUT}")

	case $menuitem in
		Back) 		break ;;
	        Cups)  		./scripts/server/printer.sh ;;
            	Minidlna)	./scripts/server/mediaserver.sh ;;
        	Web) 		./scripts/server/web.sh ;;
			Smtp) 		./scripts/server/smtp.sh ;;
        	WebDAV) 	./scripts/server/webdav.sh ;;
        	SMB) 	./scripts/server/fileserver.sh ;;
        	OwnCloud) 	./scripts/server/owncloud.sh ;;
            	FWork)		./scripts/server/fwork.sh ;;
        	DB) 		./scripts/server/db.sh ;;
	esac
done
}

function smOthers(){
while true
do

	$DIALOG --clear   \
		--backtitle 	"$TITLE" \
		--title 	"[ Others ]" \
		--menu  	"Another scripts uncategorized" $wHEIGHT $wWIDTH 4 \
        	Back  		"Back to main menu" \
        	SDL2  		"Compile SDL2 + Libraries (It can take 40 minutes)" \
			GCC  		"Install GCC 4.7 on Raspberry Pi" \
        	WhatsApp  	"Send WhatsApp messages from terminal" \
        	Aircrack	"Compile Aircrack-NG suite easily" 2>"${INPUT}"

	menuitem=$(<"${INPUT}")

	case $menuitem in
            	Back) 		break ;;
            	SDL2) 		./scripts/others/sdl2.sh ;;
				GCC) 		./scripts/others/gcc47.sh ;;
        	WhatsApp) 	./scripts/others/whatsapp.sh ;;
        	Aircrack)       ./scripts/others/aircrack.sh ;;
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

	$DIALOG --clear   \
		--backtitle "$TITLE" \
		--title		"[ M A I N - M E N U ]" \
		--menu 		"You can use the UP/DOWN arrow keys, the first letter of the choice as a hot key, or the number keys 1-4 to choose an option." $wHEIGHT $wWIDTH 4 \
		Tweaks 		"Put your distro to the limit" \
		Games 		"Install or compile games easily" \
        	Emula 		"Install emulators" \
		Info		"Info about the Pi or related" \
		Multimedia	"Help you to install apps like XBMC" \
		Configure 	"Installations are piece of cake now" \
		Internet 	"All refered to internet" \
		Server 		"Use your distro like a server" \
		Others 		"Scripts with others thematics" \
		Exit 		"Exit to the shell" 2>"${INPUT}"

	menuitem=$(<"${INPUT}")

	case $menuitem in
		Tweaks)	    	smTweaks ;;
		Games) 	    	smGames ;;
	        Emula)	    	smEmulators ;;
		Info)	    	smInfo ;;
		Multimedia) 	smMultimedia ;;
		Configure)  	smConfigure ;;
		Internet)   	smInternet ;;
		Server)     	smServer ;;
		Others)     	smOthers ;;
		Exit) 	    	echo -e "\nThanks for visiting http://misapuntesde.com" && exit ;;
1)
    echo -e "\nCancel pressed." && exit;;
  255)
    echo -e "\nESC pressed." && exit;;
	esac
done

#
# - - - - - - -
# DEL TMP FILES
# - - - - - - -
#
[ -f $OUTPUT ] && rm $OUTPUT
[ -f $INPUT ] && rm $INPUT
