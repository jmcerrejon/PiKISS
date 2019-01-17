#!/bin/bash
# - - - - - - - - - - - - - - - - - -
# PiKISS (Pi Keeping simple, stupid!)
# - - - - - - - - - - - - - - - - - -
#
# Author  : Jose Cerrejon Gonzalez
# Mail    : ulysess@gmail_dot_com
# Version : Check VERSION variable
#
# USE AT YOUR OWN RISK!
#
# - - - -
# INCLUDE
# - - - -
#

. ./scripts/helper.sh || . ../helper.sh || . ./helper.sh || wget -q 'http://github.com/jmcerrejon/PiKISS/raw/master/scripts/helper.sh'
check_board || { echo "Missing file helper.sh. I've tried to download it for you. Try to run the script again." && exit 1; }

VERSION="v.1.1.0 (2019)"
check_board
check_temperature
check_CPU
mkDesktopEntry
IP=$(get_ip)

#
# - - - - -
# VARIABLES
# - - - - -
#

TITLE="PiKISS (Pi Keeping It Simple, Stupid!) ${VERSION} .:. Jose Cerrejon | IP=${IP} ${CPU}| Model=${MODEL}"
CHK_UPDATE=0
NOINTERNETCHECK=0
wHEIGHT=20
wWIDTH=70

#
# - - - - -
# FUNCTIONS
# - - - - -
#

function usage()
{
  echo -e "$TITLE\n\nScript designed to config or install apps on Raspberry Pi(Raspbian) or ODROID-C1(Ubuntu) easier for everyone.\n"
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
      read -p "Missing 'dialog' package. Do you wish to let me try to install it for you? (aprox. 1.3 kB) [y/n] " yn
      case $yn in
        [Yy]* ) sudo apt install -y dialog; break ;;
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
check_internet_available
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

  cmd=(dialog --clear --backtitle "$TITLE" --title "[ Info ]" --menu "Select an option from the list:" $wHEIGHT $wWIDTH $wHEIGHT)

  # common options, working on any model
  options=(
      Back "Back to main menu"
      Weather "Weather info from your country"
      Chkimg "Check some distros images to know if they are updated"
  )
  if [[ ${MODEL} == 'Raspberry Pi' ]]; then
    options+=(
      Webmin "Monitoring tool"
      Bmark "Benchmark RPi (CPU, MEM, SD Card...)"
      Lynis "Lynis is a security auditing tool."
      TestInet "Test Internet bandwidth"
      WebMonitor "Web monitor to your RPi"
    )
  fi

  choices=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)

  for choice in $choices
  do
    case $choice in
      Back)		break ;;
      Chkimg) 	./scripts/info/check_lastmod_img.sh ;;
      Webmin) 	./scripts/info/webmin.sh ;;
      Weather) 	./scripts/info/weather.sh ;;
      Bmark) 		./scripts/info/bmark.sh ;;
      Lynis) 		./scripts/info/lynis.sh ;;
      TestInet) 	./scripts/info/test_inet.sh ;;
      WebMonitor)	./scripts/info/web_monitor.sh ;;
    esac
  done
}

function smTweaks(){

  cmd=(dialog --clear --backtitle "$TITLE" --title "[ Tweaks ]" --menu "Select a tweak from the list:" $wHEIGHT $wWIDTH $wHEIGHT)

  if [[ ${MODEL} == 'Raspberry Pi' ]]; then
    options=(
      Back "Back to main menu"
      # Autologin "Set autologin for the pi user"
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

  cmd=(dialog --clear --backtitle "$TITLE" --title "[ Games ]" --menu "Select game from the list:" $wHEIGHT $wWIDTH $wHEIGHT)

  if [[ ${MODEL} == 'Raspberry Pi' ]]; then
    options=(
      Back "Back to main menu"
      GMaker "(Only Jessie) Maldita Castilla, Super Crate Box and They Need to be Fed"
      OpenBor "OpenBOR is the open source continuation of Beats of Rage"
      Dune2 "Dune 2 Legacy"
      Descent "Descent 1 & 2 Shareware Ed."
      RWolf "(Jessie) Return to Castle Wolfenstein (Demo)"
      Crispy-doom "Crispy to play Doom, Heretic, Hexen, Strife"
      Sqrxz4 "Sqrxz 4: Difficult platform game"
      Xump "Xump: Simple multi-platform puzzler"
      Giana "Giana's Return: Simple multi-platform puzzler"
      Fruity "Fruit'Y: Better than Candy Crush!"
    )
  elif [[ ${MODEL} == 'ODROID-C1' ]]; then
    options=(
      Back "Back to main menu"
      Crispy-doom "Crispy to play Doom, Heretic, Hexen, Strife"
      Quake "Quake 2"
    )
  elif [[ ${MODEL} == 'Debian' ]]; then
    options=(
      Back "Back to main menu"
      OpenBor "OpenBOR is the open source continuation of Beats of Rage"
      Arx-Fatalis "3D 1st person RPG"
    )
  fi

  choices=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)

  for choice in $choices
  do
    case $choice in
      Back) 		 break ;;
      GMaker)      ./scripts/games/gmaker.sh ;;
      OpenBor)     ./scripts/games/openbor.sh ;;
      Arx-Fatalis) ./scripts/games/arx.sh ;;
      Dune2) 		 ./scripts/games/dune2.sh ;;
      Descent) 	 ./scripts/games/descent.sh ;;
      Quake) 		 ./scripts/games/quake.sh ;;
      RWolf) 		 ./scripts/games/rwolf.sh ;;
      Crispy-doom) ./scripts/games/cdoom.sh ;;
      Sqrxz4) 	 ./scripts/games/sqrxz4.sh ;;
      Xump) 	 	 ./scripts/games/xump.sh ;;
      Giana) 	 	 ./scripts/games/giana.sh ;;
      Fruity) 	 	 ./scripts/games/fruity.sh ;;
    esac
  done
}

function smEmulators(){
  cmd=(dialog --clear --backtitle "$TITLE" --title "[ Emulators ]" --menu "Select emulator from the list:" $wHEIGHT $wWIDTH $wHEIGHT)

  if [[ ${MODEL} == 'Raspberry Pi' ]]; then
    options=(
      Back "Back to main menu"
      Genesis "Genesis Megadrive Emulator (picodrive)"
      Caprice "Amstrad CPC Caprice for RPi 2"
      Snes "SNES Emulator port based on SNES9X 1.39"
      Mame "Install MAME, Advance MAME and/or MAME4ALL-PI"
      Speccy "ZX-Spectrum emulator"
      Rpix86 "rpix86 MS-DOS emulator"
      8086 "Compile 8086 PC XT-compatible"
      Amiga "UAE4ARM Amiga emulator"
      Gba "Gameboy Advance"
      PCE-CD "PC-Engine"
      MSX "openMSX"
      Pifba "Emulates old arcade games using CPS1, CPS2,..."
      ScummVM "Allow gamers to play point-and-click adventure games"
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
      Genesis) 	./scripts/emus/genesis.sh ;;
      Caprice) 	./scripts/emus/caprice.sh ;;
      Snes) 		./scripts/emus/pisnes.sh ;;
      Mame) 	./scripts/emus/mame4allpi.sh ;;
      Speccy) 	./scripts/emus/speccy.sh ;;
      Amiga) 		./scripts/emus/amiga.sh ;;
      Rpix86) 	./scripts/emus/rpix86.sh ;;
      8086) 		./scripts/emus/8086tiny.sh ;;
      Gba)        ./scripts/emus/gba.sh ;;
      PCE-CD)     ./scripts/emus/pce.sh ;;
      MSX)     	./scripts/emus/msx.sh ;;
      Pifba) 		./scripts/emus/pifba.sh ;;
      ScummVM) 	./scripts/emus/scummvm.sh ;;
    esac
  done
}


function smMultimedia(){
  cmd=(dialog --clear --backtitle "$TITLE" --title "[ Multimedia ]" --menu "Select a script from the list:" $wHEIGHT $wWIDTH $wHEIGHT)

  if [[ ${MODEL} == 'Raspberry Pi' ]]; then
    options=(
      Back "Back to main menu"
      Rplay "XBMC Kodi 16.1"
      Airplay "AirPlay Mirroring on your Pi with RPlay"
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
      Rplay)		./scripts/mmedia/xbmc.sh ;;
      Airplay)	./scripts/mmedia/airplay.sh ;;
      Kiosk)      ./scripts/mmedia/kiosk.sh ;;
      XBMC) 		./scripts/mmedia/xbmc.sh ;;
    esac
  done
}

function smConfigure(){
  cmd=(dialog --clear --backtitle "$TITLE" --title "[ Configure ]" --menu "Select to configure your distro:" $wHEIGHT $wWIDTH $wHEIGHT)

  if [[ ${MODEL} == 'Raspberry Pi' ]]; then
    options=(
      Back "Back to main menu"
      RaspNet "Configure Raspbian Net Install distro"
      SSIDCfg "Configure SSID (WPA/WPA2 with PSK)"
      Joypad "Configure WII, XBox360 controller"
      Backup "Simple backup dir to run daily"
      # Applekeyb "Bluetooth keyboard"
      Netcfg "Configure static IP"
      Monitorcfg "Configure your TV resolution"
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
      SSIDCfg)    ./scripts/config/ssidcfg.sh;;
      Joypad) 	./scripts/config/jpad.sh;;
      Backup) 	./scripts/config/backup.sh;;
      Applekeyb) 	./scripts/config/applekeyb.sh;;
      Netcfg) 	./scripts/config/netconfig.sh;;
      Monitorcfg) ./scripts/config/monitorcfg.sh;;
    esac
  done
}

function smInternet(){
  cmd=(dialog --clear --backtitle "$TITLE" --title "[ Internet ]" --menu "Select an option from the list:" $wHEIGHT $wWIDTH $wHEIGHT)

  if [[ ${MODEL} == 'Raspberry Pi' ]]; then
    options=(
      Back "Back to main menu"
      Plowshare "Direct download from hosters like uploaded,..."
      # Browser "Web browser"
      # Downmp3 "Download mp3 from GrooveShark"
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
      Browser)   ./scripts/inet/browser.sh ;;
      Downmp3) 	./scripts/inet/dwnmp3.sh ;;
    esac
  done
}

function smServer(){
  cmd=(dialog --clear --backtitle "$TITLE" --title "[ Server ]" --menu "Select to configure your distro as a server:" $wHEIGHT $wWIDTH $wHEIGHT)

  # options working on any board
  options=(
      Back "Back to main menu"
      FTP "Simple FTP Server with vsftpd"
      Cups "Printer server (cups)"
  )
  if [[ ${MODEL} == 'Raspberry Pi' ]]; then
    options+=(
      VNCServer "Share Desktop through VNC Server"
      VPNServer "OpenVPN setup and config thks to pivpn.io"
      Nagios "Nagios 3 is a network host and service monitoring"
      AdBlock "Turn Raspberry Pi into ad blocker"
      Minidlna "Install/Compile UPnP/DLNA Minidlna"
      Web "Web server+PHP7"
      Smtp "SMTP Config to send e-mail"
      WebDAV "WebDAV to share local content with Apache"
      SMB "Share files with SAMBA"
      OwnCloud "Access your data from all your devices"
      GitServer "Use your RPi like a Git Server"
      FWork "Wordpress, Node.js among others"
      DB "MySQL+PHP5 connector"
      Upd "keep Debian patched with latest security updates"
      BtSync "Bittorrent Sync as file backup service"
    )
  fi
  # last entries
  options+=(
      OctoPrint "Control your 3D-Printer"
  )

  choices=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)

  for choice in $choices
  do
    case $choice in
      Back) 		break ;;
      VNCServer) ./scripts/server/vncserver.sh ;;
      VPNServer) ./scripts/server/openvpn.sh ;;
      Nagios)  	 ./scripts/server/nagios.sh ;;
      AdBlock)   ./scripts/server/adblock.sh ;;
      Cups)  		 ./scripts/server/printer.sh ;;
      FTP)  		 ./scripts/server/ftp.sh ;;
      Minidlna)	 ./scripts/server/mediaserver.sh ;;
      Web) 		   ./scripts/server/web.sh ;;
      Smtp) 		 ./scripts/server/smtp.sh ;;
      WebDAV) 	 ./scripts/server/webdav.sh ;;
      SMB) 		   ./scripts/server/fileserver.sh ;;
      OwnCloud)  ./scripts/server/owncloud.sh ;;
      GitServer) ./scripts/server/gitserver.sh ;;
      FWork)		 ./scripts/server/fwork.sh ;;
      DB) 		   ./scripts/server/db.sh ;;
      Upd)       ./scripts/server/auto-upd.sh ;;
      BtSync)    ./scripts/server/bsync.sh ;;
      OctoPrint)    ./scripts/server/octoprint.sh ;;
    esac
  done
}

function smOthers(){
  cmd=(dialog --clear --backtitle "$TITLE" --title "[ Others ]" --menu "Another scripts uncategorized:" $wHEIGHT $wWIDTH $wHEIGHT)

  if [[ ${MODEL} == 'Raspberry Pi' ]]; then
    options=(
      Back "Back to main menu"
      NetTools "MITM Pentesting Opensource Toolkit (Require X)"
      Part "Check issues & fix SD corruptions"
      SDL2 "Compile/Install SDL2 + Libraries"
      GCC "Install GCC 4.7 on Raspberry Pi"
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
  cmd=(dialog --clear --backtitle "$TITLE" --title	"[ M A I N - M E N U ]" --menu "You can use the UP/DOWN arrow keys, the first letter of the choice as a hot key, or the number keys 1-9 to choose an option:" $wHEIGHT $wWIDTH $wHEIGHT)

  options=(
    Tweaks "Put your distro to the limit"
    Games "Install or compile games easily"
    Emula "Install emulators"
    Info "Info about the Pi or related"
    Multimedia "Help you to install apps like XBMC"
    Configure "Installations are piece of cake now"
    Internet "All refered to internet"
    Server "Use your distro as a server"
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
