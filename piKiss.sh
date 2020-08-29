#!/bin/bash
#
# PiKISS (Pi Keeping simple, stupid!)
#
# Author  : Jose Cerrejon Gonzalez
# Mail    : ulysess@gmail_dot_com
# Version : Check VERSION variable
#

. ./scripts/helper.sh || . ../helper.sh || . ./helper.sh || wget -q 'https://github.com/jmcerrejon/PiKISS/raw/master/scripts/helper.sh'
clear
check_board || { echo "Missing file helper.sh. I've tried to download it for you. Try to run the script again." && exit 1; }

VERSION="v.1.6.0"
IP=$(get_ip)
TITLE="PiKISS (Pi Keeping It Simple, Stupid!) ${VERSION} .:. Jose Cerrejon | IP=${IP} ${CPU}| Model=${MODEL}"
CHK_UPDATE=0
CHK_PIKISS_UPDATE=0
NOINTERNETCHECK=0
wHEIGHT=20
wWIDTH=82
check_board
check_temperature
check_CPU
make_desktop_entry


usage() {
    echo -e "$TITLE\n\nScript designed to config or install apps on Raspberry Pi easier for everyone.\n"
    echo -e "Usage: ./piKiss.sh [Arguments]\n\nArguments:\n"
    echo "-h   | --help       		: This help."
    echo "-nu  | --no-update  	 	: No check if repositories are updated."
    echo "-nup | --no-update-pikiss : No check if PiKISS are updated."
    echo "-ni  | --noinet     		: No check if internet connection is available."
    echo
    echo "For trouble, ideas or technical support please visit https://github.com/jmcerrejon/PiKISS"
}

#
# Initial checks
#

# Arguments
while [ "$1" != "" ]; do
    case $1 in
    -nu | --no_update)
        export CHK_UPDATE=1
        ;;
    -nup | --no_update-pikiss)
        export CHK_PIKISS_UPDATE=1
        ;;
    -ni | --noinet)
        export NOINTERNETCHECK=1
        ;;
    -h | --help)
        usage
        exit
        ;;
    *)
        usage
        exit 1
        ;;
    esac
    shift
done

is_missing_dialog_pkg
check_internet_available
# last_update_repo # TODO Test this feature
check_update_pikiss

#
# Menu
#
smInfo() {
    cmd=(dialog --clear --backtitle "$TITLE" --title "[ Info ]" --menu "Select an option from the list:" "$wHEIGHT" "$wWIDTH" "$wHEIGHT")

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

    for choice in $choices; do
        case $choice in
        Back) break ;;
        Chkimg) ./scripts/info/check_lastmod_img.sh ;;
        Webmin) ./scripts/info/webmin.sh ;;
        Weather) ./scripts/info/weather.sh ;;
        Bmark) ./scripts/info/bmark.sh ;;
        Lynis) ./scripts/info/lynis.sh ;;
        TestInet) ./scripts/info/test_inet.sh ;;
        WebMonitor) ./scripts/info/web_monitor.sh ;;
        esac
    done
}

smTweaks() {
    cmd=(dialog --clear --backtitle "$TITLE" --title "[ Tweaks ]" --menu "Select a tweak from the list:" "$wHEIGHT" "$wWIDTH" "$wHEIGHT")

    if [[ ${MODEL} == 'Raspberry Pi' ]]; then
        options=(
            Back "Back to main menu"
            # Autologin "Set autologin for the pi user"
            Others "CPU performance, disable Ethernet and so on"
            Packages "Programs you don't use (maybe) to free space"
            Daemons "Disable services useless"
            ZRAM "Enable/Disable ZRAM"
        )
    fi

    choices=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)

    for choice in $choices; do
        case $choice in
        Back) break ;;
        Autologin) ./scripts/tweaks/autologin.sh ;;
        Others) ./scripts/tweaks/others.sh ;;
        Packages) ./scripts/tweaks/removepkg.sh ;;
        Daemons) ./scripts/tweaks/services.sh ;;
        ZRAM) ./scripts/tweaks/zram.sh ;;
        esac
    done
}

smGames() {
    cmd=(dialog --clear --backtitle "$TITLE" --title "[ Games ]" --menu "Select game from the list:" "$wHEIGHT" "$wWIDTH" "$wHEIGHT")

    if [[ ${MODEL} == 'Raspberry Pi' ]]; then
        options=(
            Back "Back to main menu"
            Abbaye "L’Abbaye des Morts is a retro puzzle platformer by Locomalito"
            Arx "Arx Fatalis is a fps RPG set on a world whose sun has failed"
            Blood "Blood is a fps game developed by Monolith Productions"
            CaptainS "Save Seville from the evil Torrebruno"
            Crispy-doom "Crispy to play Doom or Heretic"
            Descent "Descent 1 & 2 Shareware Ed."
            Dune2 "Dune 2 Legacy"
            Diablo "Take control of a lone hero battling to rid the world of Diablo"
            Diablo2 "Diablo 2 Lord of Destruction"
            Eduke32 "Duke Nukem 3D is a fps game developed by 3D Realms"
            AVP "Aliens versus Predator is a 1999 SF fps published by Fox Interactive"
            Hurrican "Jump and shoot game based on the Turrican game series"
            OpenBor "OpenBOR is the open source continuation of Beats of Rage"
            OpenSPlex "OpenSupaplex reimplementation of the original 90's game"
            OpenXCom "Open-source clone of UFO: Enemy Unknown"
            Quake "Enhanced client for id Software's Quake ]["
            Revolt "Re-Volt is a radio control car racing themed video game"
            SMario64 "Super Mario 64 native OpenGL ES"
            SpelunkyHD "Spelunky is a cave exploration/treasure-hunting game"
            Sqrxz4 "Sqrxz 4: Difficult platform game"
            SSam12 "Serious Sam I & II. Kill all walking monster"
            Xump "Xump: Simple multi-platform puzzler"
        )
    fi

    choices=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)

    for choice in $choices; do
        case $choice in
        Back) break ;;
        Abbaye) ./scripts/games/abbaye.sh ;;
        Arx) ./scripts/games/arx.sh ;;
        Blood) ./scripts/games/blood.sh ;;
        CaptainS) ./scripts/games/captains.sh ;;
        Crispy-doom) ./scripts/games/cdoom.sh ;;
        Descent) ./scripts/games/descent.sh ;;
        Dune2) ./scripts/games/dune2.sh ;;
        Diablo) ./scripts/games/diablo.sh ;;
        Diablo2) ./scripts/games/diablo2.sh ;;
        Eduke32) ./scripts/games/eduke32.sh ;;
        AVP) ./scripts/games/avp.sh ;;
        Hurrican) ./scripts/games/hurrican.sh ;;
        OpenBor) ./scripts/games/openbor.sh ;;
        OpenSPlex) ./scripts/games/supaplex.sh ;;
        OpenXCom) ./scripts/games/openxcom.sh ;;
        Quake) ./scripts/games/quake.sh ;;
        Revolt) ./scripts/games/revolt.sh ;;
        SMario64) ./scripts/games/smario64.sh ;;
        SpelunkyHD) ./scripts/games/spelunky.sh ;;
        Sqrxz4) ./scripts/games/sqrxz4.sh ;;
        SSam12) ./scripts/games/ssam.sh ;;
        Xump) ./scripts/games/xump.sh ;;
        esac
    done
}

smEmulators() {
    cmd=(dialog --clear --backtitle "$TITLE" --title "[ Emulators ]" --menu "Select emulator from the list:" "$wHEIGHT" "$wWIDTH" "$wHEIGHT")

    if [[ ${MODEL} == 'Raspberry Pi' ]]; then
        options=(
            Back "Back to main menu"
            Amiga "Amiga (Amiberry)"
            AMSTRAD_CPC "Amstrad CPC (Caprice32)"
            GBA "Game Boy Advance (mGBA)"
            MAME "Multiple Arcate Machine Emulator (MAME, AdvanceMAME, and/or MAME4ALL-Pi)"
            Mednafen "Portable multi-system emulator (Mednafen)"
            MSDOS "MS-DOS (DOSBox)"
            MSX "MSX (openMSX)"
            PiFBA "Emulates old arcade games using MAME ROMS for CPS1, CPS2, and more"
            PSP "PlayStation Portable (PPSSPP)"
            ResidualVM "Cross-platform 3D game interpreter to play LucasArts adventure games and more"
            ScummVM "Emulator for point-and-click adventure games"
            Sega "Sega Genesis, Megadrive, Mega CD, 32X (PicoDrive)"
            SNES "Super NES (Snes9X 1.60)"
            Wii_GC "[EXPERIMENTAL] Wii & Gamecube (Dolphin)"
            ZX_Spectrum "ZX Spectrum (Speccy)"
        )
    fi

    choices=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)

    for choice in $choices; do
        case $choice in
        Back) break ;;
        Amiga) ./scripts/emus/amiga.sh ;;
        AMSTRAD_CPC) ./scripts/emus/caprice.sh ;;
        GBA) ./scripts/emus/gba.sh ;;
        MAME) ./scripts/emus/mame4allpi.sh ;;
        Mednafen) ./scripts/emus/mednafen.sh ;;
        MSDOS) ./scripts/emus/rpix86.sh ;;
        MSX) ./scripts/emus/msx.sh ;;
        PiFBA) ./scripts/emus/pifba.sh ;;
        PSP) ./scripts/emus/psp.sh ;;
        ResidualVM) ./scripts/emus/residual.sh ;;
        ScummVM) ./scripts/emus/scummvm.sh ;;
        Sega) ./scripts/emus/genesis.sh ;;
        SNES) ./scripts/emus/pisnes.sh ;;
        Wii_GC) ./scripts/emus/dolphin.sh ;;
        ZX_Spectrum) ./scripts/emus/speccy.sh ;;
        esac
    done
}

smMultimedia() {
    cmd=(dialog --clear --backtitle "$TITLE" --title "[ Multimedia ]" --menu "Select a script from the list:" "$wHEIGHT" "$wWIDTH" "$wHEIGHT")

    if [[ ${MODEL} == 'Raspberry Pi' ]]; then
        options=(
            Back "Back to main menu"
            Kodi "Kodi is a free media player that is designed to look great on your TV but is just as home on a small screen."
            Kiosk "Image slideshow"
            OBS "Free & open source software 4 video recording and streaming"
        )
    fi

    choices=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)

    for choice in $choices; do
        case $choice in
        Back) break ;;
        Kodi) ./scripts/mmedia/xbmc.sh ;;
        Kiosk) ./scripts/mmedia/kiosk.sh ;;
        OBS) ./scripts/mmedia/obs.sh ;;
        esac
    done
}

smConfigure() {
    cmd=(dialog --clear --backtitle "$TITLE" --title "[ Configure ]" --menu "Select to configure your distro:" "$wHEIGHT" "$wWIDTH" "$wHEIGHT")

    if [[ ${MODEL} == 'Raspberry Pi' ]]; then
        options=(
            Back "Back to main menu"
            Vulkan "Compile/update Vulkan Mesa driver (EXPERIMENTAL)"
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

    for choice in $choices; do
        case $choice in
        Back) break ;;
        Vulkan) ./scripts/config/vulkan.sh ;;
        RaspNet) ./scripts/config/raspnetins.sh ;;
        SSIDCfg) ./scripts/config/ssidcfg.sh ;;
        Joypad) ./scripts/config/jpad.sh ;;
        Backup) ./scripts/config/backup.sh ;;
        Applekeyb) ./scripts/config/applekeyb.sh ;;
        Netcfg) ./scripts/config/netconfig.sh ;;
        Monitorcfg) ./scripts/config/monitorcfg.sh ;;
        esac
    done
}

smInternet() {
    cmd=(dialog --clear --backtitle "$TITLE" --title "[ Internet ]" --menu "Select an option from the list:" "$wHEIGHT" "$wWIDTH" "$wHEIGHT")

    if [[ ${MODEL} == 'Raspberry Pi' ]]; then
        options=(
            Back "Back to main menu"
            Cordless "Discord client that aims to have a low memory footprint"
            # Plowshare "Direct download from hosters like uploaded,..."
            # Browser "Web browser"
            # Downmp3 "Download mp3 from GrooveShark"
        )
    fi

    choices=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)

    for choice in $choices; do
        case $choice in
        Back) break ;;
        Cordless) ./scripts/inet/discord.sh ;;
        Plowshare) ./scripts/inet/ddown.sh ;;
        Browser) ./scripts/inet/browser.sh ;;
        Downmp3) ./scripts/inet/dwnmp3.sh ;;
        esac
    done
}

smServer() {
    cmd=(dialog --clear --backtitle "$TITLE" --title "[ Server ]" --menu "Select to configure your distro as a server:" "$wHEIGHT" "$wWIDTH" "$wHEIGHT")

    if [[ ${MODEL} == 'Raspberry Pi' ]]; then
        options=(
            Back "Back to main menu"
            AdBlock "Turn Raspberry Pi into an Ad blocker"
            BtSync "Bittorrent Sync as file backup service"
            Cups "Printer server (cups)"
            DB "MySQL+PHP5 connector"
            FTP "Simple FTP Server with vsftpd"
            FWork "WordPress, Node.js among others"
            GitServer "Use your RPi as a Git Server"
            Jenkins "Jenkins is a free and open source automation server"
            Minidlna "Install/Compile UPnP/DLNA Minidlna"
            Nagios "Nagios is a network host and service monitoring"
            OctoPrint "Control your 3D-Printer"
            OwnCloud "Access your data from all your devices"
            Smtp "SMTP Config to send e-mail"
            SMB "Share files with SAMBA"
            Upd "keep Debian patched with latest security updates"
            VNCServer "Share Desktop through VNC Server"
            VPNServer "OpenVPN setup and config thks to pivpn.io"
            Web "Web server+PHP7"
            WebDAV "WebDAV to share local content with Apache"
        )
    fi

    choices=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)

    for choice in $choices; do
        case $choice in
        Back) break ;;
        AdBlock) ./scripts/server/adblock.sh ;;
        BtSync) ./scripts/server/bsync.sh ;;
        Cups) ./scripts/server/printer.sh ;;
        DB) ./scripts/server/db.sh ;;
        FTP) ./scripts/server/ftp.sh ;;
        FWork) ./scripts/server/fwork.sh ;;
        GitServer) ./scripts/server/gitserver.sh ;;
        Jenkins) ./scripts/server/jenkins.sh ;;
        Minidlna) ./scripts/server/mediaserver.sh ;;
        Nagios) ./scripts/server/nagios.sh ;;
        OctoPrint) ./scripts/server/octoprint.sh ;;
        OwnCloud) ./scripts/server/owncloud.sh ;;
        Smtp) ./scripts/server/smtp.sh ;;
        SMB) ./scripts/server/fileserver.sh ;;
        Upd) ./scripts/server/auto-upd.sh ;;
        VNCServer) ./scripts/server/vncserver.sh ;;
        VPNServer) ./scripts/server/openvpn.sh ;;
        Web) ./scripts/server/web.sh ;;
        WebDAV) ./scripts/server/webdav.sh ;;
        esac
    done
}

smDevs() {
    cmd=(dialog --clear --backtitle "$TITLE" --title "[ Developers ]" --menu "Select to configure some apps for development:" "$wHEIGHT" "$wWIDTH" "$wHEIGHT")

    # options working on any board
    options=(
        Back "Back to main menu"
        QT5 "Free and open-source widget toolkit for creating graphical UI cross-platform applications"
        TIC80 "TIC-80 is a free fantasy computer for making, playing tiny games"
        VSCode "Code - OSS (VSCode fork)"
    )

    choices=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)

    for choice in $choices; do
        case $choice in
        Back) break ;;
        QT5) ./scripts/devs/qt5.sh ;;
        TIC80) ./scripts/devs/tic-80.sh ;;
        VSCode) ./scripts/devs/vscode.sh ;;
        esac
    done
}

smOthers() {
    cmd=(dialog --clear --backtitle "$TITLE" --title "[ Others ]" --menu "Another scripts uncategorized:" "$wHEIGHT" "$wWIDTH" "$wHEIGHT")

    if [[ ${MODEL} == 'Raspberry Pi' ]]; then
        options=(
            Back "Back to main menu"
            Aircrack "Compile Aircrack-NG suite easily"
            CoolTerm "Compile a terminal with the look and feel of the old cathode tube screens"
            Fixes "Fix some problems with the Raspbian OS"
            NetTools "MITM Pentesting Opensource Toolkit (Require X)"
            Part "Check issues & fix SD corruptions"
            RPiPlay "An open-source implementation of an AirPlay mirroring server"
            Scrcpy "Display and control of Android devices connected on USB"
            SDL2 "Compile/Install SDL2 + Libraries"
            ShaderToy "Render over 100+ OpenGL ES 3.0 shaders"
            Synergy "Allow you to share keyboard and mouse to computers on LAN"
            Uninstall "Uninstall PiKISS :_("
        )
    fi

    choices=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)

    for choice in $choices; do
        case $choice in
        Back) break ;;
        Aircrack) ./scripts/others/aircrack.sh ;;
        CoolTerm) ./scripts/others/retro-term.sh ;;
        Fixes) ./scripts/others/fixes.sh ;;
        NetTools) ./scripts/others/nettools.sh ;;
        Part) ./scripts/others/checkpart.sh ;;
        RPiPlay) ./scripts/others/rpiplay.sh ;;
        Scrcpy) ./scripts/others/scrcpy.sh ;;
        SDL2) ./scripts/others/sdl2.sh ;;
        ShaderToy) ./scripts/others/shadertoy.sh ;;
        Synergy) ./scripts/others/synergy.sh ;;
        Uninstall) uninstall_pikiss ;;
        esac
    done
}

#
# Main menu
#
while true; do
    cmd=(dialog --clear --backtitle "$TITLE" --title " [ M A I N - M E N U ] " --menu "You can use the UP/DOWN arrow keys, the first letter of the choice as a hot key, or the number keys 1-9 to choose an option:" "$wHEIGHT" "$wWIDTH" "$wHEIGHT")

    options=(
        Tweaks "Put your distro to the limit"
        Games "Install or compile games easily"
        Emulation "Install emulators"
        Info "Info about the Pi or related"
        Multimedia "Help you to install apps like XBMC"
        Configure "Installations are piece of cake now"
        Internet "All refered to internet"
        Server "Use your distro as a server"
        Devs "Help you for making your own apps"
        Others "Scripts with others thematics"
        Exit "Exit to the shell"
    )

    choices=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)

    for choice in $choices; do
        case $choice in
        Tweaks) smTweaks ;;
        Games) smGames ;;
        Emulation) smEmulators ;;
        Info) smInfo ;;
        Multimedia) smMultimedia ;;
        Configure) smConfigure ;;
        Internet) smInternet ;;
        Server) smServer ;;
        Devs) smDevs ;;
        Others) smOthers ;;
        Exit) clear && exit_pikiss ;;
        1)
            echo -e "\nCancel pressed." && exit
            ;;
        255)
            echo -e "\nESC pressed." && exit
            ;;
        esac
    done
done
