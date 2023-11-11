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

VERSION="v.1.11.0"
IP=$(get_ip)
PI_VERSION_NUMBER=$(get_pi_version_number)
ARCHITECTURE=$(getconf LONG_BIT)
CPU_FREQUENCY=$(get_cpu_frequency)
TITLE="PiKISS (Pi Keeping It Simple, Stupid!) ${VERSION} | ${ARCHITECTURE} Bits | ${IP} | ${MODEL} ${PI_VERSION_NUMBER} (${CPU_FREQUENCY} Mhz)"
CHK_UPDATE=0
CHK_PIKISS_UPDATE=0
NOINTERNETCHECK=0
wHEIGHT=20
wWIDTH=90
check_board
check_temperature
make_desktop_entry
remove_unneeded_helper

usage() {
    echo -e "$TITLE\n\nScript designed to config or install apps on Raspberry Pi easier for everyone.\n"
    echo -e "Usage: ./piKiss.sh [Arguments]\n\nArguments:\n"
    echo "-h   | --help             : This help."
    echo "-nu  | --no-update        : No check if repositories are updated."
    echo "-nup | --no-update-pikiss : No check if PiKISS are updated."
    echo "-ni  | --noinet           : No check if internet connection is available."
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
check_update_pikiss

#
# Menus
#

smInfo() {
    cmd=(dialog --clear --backtitle "$TITLE" --title "[ Info ]" --menu "Select an option from the list:" "$wHEIGHT" "$wWIDTH" "$wHEIGHT")

    options=(
        Back "Back to main menu"
        Weather "Weather info from your country"
        Chkimg "Check some distros images to know if they are updated"
        Webmin "Monitoring tool"
        Bmark "Benchmark RPi (CPU, MEM, SD Card...)"
        Lynis "Lynis is a security auditing tool."
        TestInet "Test Internet bandwidth"
        WebMonitor "Web monitor to your RPi"
    )

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

    options=(
        Back "Back to main menu"
        Others "CPU performance, disable Ethernet and so on"
        Packages "Programs you don't use (maybe) to free space"
        Daemons "Disable useless services"
        ZRAM "Enable/Disable ZRAM"
    )

    choices=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)

    for choice in $choices; do
        case $choice in
        Back) break ;;
        Others) ./scripts/tweaks/others.sh ;;
        Packages) ./scripts/tweaks/removepkg.sh ;;
        Daemons) ./scripts/tweaks/services.sh ;;
        ZRAM) ./scripts/tweaks/zram.sh ;;
        esac
    done
}

smGames() {
    if is_userspace_64_bits; then
        show_dialog_only_32_bits "Abbaye, Blake Stone, EDuke32, Fallout 2, GTA, GemRB, Quake I-II, SMario64, Serious Sam, OpenXCom"
    fi
    cmd=(dialog --clear --backtitle "$TITLE" --title "[ Games ]" --menu "Select game from the list:" "$wHEIGHT" "$wWIDTH" "$wHEIGHT")

    options=(
        Back "Back to main menu"
        Abbaye "L’Abbaye des Morts is a retro puzzle platformer by Locomalito"
        AVP "Aliens versus Predator is a 1999 SF fps published by Fox Interactive"
        Arx "Arx Fatalis is a fps RPG set on a world whose sun has failed"
        Blood "Blood is a fps game developed by Monolith Productions"
        BStone "Robert W. Stone III, AKA Blake Stone must eliminate Dr. Pyrus Goldfire"
        CaptainS "Save Seville from the evil Torrebruno"
        Doom_engine "Zendronum or Crispy engine to play Doom, Heretic, Hexen..."
        Descent "Descent 1 & 2 Shareware Ed."
        Dune2 "Dune 2 Legacy"
        Diablo "Take control of a lone hero battling to rid the world of Diablo"
        Diablo2 "Diablo 2 Lord of Destruction"
        Eduke32 "Duke Nukem 3D is a fps game developed by 3D Realms"
        Fallout "Fallout 2 is a post-apocalyptic RPG"
        GTA "GTA III/Vice City are open worlds video games part of the GTA franchise"
        GemRB "Engine for games like Baldur's Gate"
        HalfLife "Gordon Freeman must exit Black Mesa after it's invaded by aliens"
        Heroes2 "Free implementation of Heroes of Might and Magic II engine"
        Heroes3 "Open-source engine for Heroes of Might and Magic III"
        Hermes "Jump'n' Run game with plenty of bad taste humour."
        Hurrican "Jump and shoot game based on the Turrican game series"
        Morrowind "The Elder Scrolls III: Morrowind is an open-world RPG"
        OpenBor "OpenBOR is the open source continuation of Beats of Rage"
        OpenClaw "Platform 2D Captain Claw (1997) reimplementation"
        OpenJK "Engine for Star Wars Jedi Knight: Jedi Academy (SP & MP)"
        OpenRCT2 "Open Source re-implementation of RollerCoaster Tycoon 2"
        OpenSPlex "OpenSupaplex reimplementation of the original 90's game"
        OpenXCom "Open-source clone of UFO: Enemy Unknown"
        Prince "port/conversion of the DOS game Prince of Persia"
        Quake "Enhanced clients for ID Software's Quake saga"
        ReturnC "The dark reich's closing in. The time to act is now"
        Revolt "Re-Volt is a radio control car racing themed video game"
        SWarrior "FPS developed by 3D Realms and released on 1997 by GT Interactive"
        SMario64 "Super Mario 64 EX native OpenGL ES"
        SMarioWar "The game centers on players fighting each other"
        SpelunkyHD "Spelunky is a cave exploration/treasure-hunting game"
        Sqrxz4 "Sqrxz 4: Difficult platform game"
        Srb2 "3D platformer fangame based on the Sonic the Hedgehog series."
        SSam12 "Serious Sam I & II. Kill all walking monster"
        StarCraft "Expansion pack for the real-time strategy video game StarCraft"
        StepMania "StepMania is a free dance and rhythm game"
        Temptations "Platform game made exclusively for MSX computers"
        VVVVVV "Minimalist platformer: instead of jumping, you need to reverse gravity"
        Xump "Xump: Simple multi-platform puzzler"
    )

    choices=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)

    for choice in $choices; do
        case $choice in
        Back) break ;;
        Abbaye) ./scripts/games/abbaye.sh ;;
        AVP) ./scripts/games/avp.sh ;;
        Arx) ./scripts/games/arx.sh ;;
        Blood) ./scripts/games/blood.sh ;;
        BStone) ./scripts/games/bstone.sh ;;
        CaptainS) ./scripts/games/captains.sh ;;
        Doom_engine) ./scripts/games/cdoom.sh ;;
        Descent) ./scripts/games/descent.sh ;;
        Dune2) ./scripts/games/dune2.sh ;;
        Diablo) ./scripts/games/diablo.sh ;;
        Diablo2) ./scripts/games/diablo2.sh ;;
        Eduke32) ./scripts/games/eduke32.sh ;;
        Fallout) ./scripts/games/fallout.sh ;;
        GTA) ./scripts/games/gta.sh ;;
        GemRB) ./scripts/games/gemrb.sh ;;
        HalfLife) ./scripts/games/half-life.sh ;;
        Heroes2) ./scripts/games/heroes2.sh ;;
        Heroes3) ./scripts/games/heroes3.sh ;;
        Hermes) ./scripts/games/hermes.sh ;;
        Hurrican) ./scripts/games/hurrican.sh ;;
        Morrowind) ./scripts/games/openmw.sh ;;
        OpenBor) ./scripts/games/openbor.sh ;;
        OpenClaw) ./scripts/games/openclaw.sh ;;
        OpenJK) ./scripts/games/openjk.sh ;;
        OpenRCT2) ./scripts/games/openrct2.sh ;;
        OpenSPlex) ./scripts/games/supaplex.sh ;;
        OpenXCom) ./scripts/games/openxcom.sh ;;
        Prince) ./scripts/games/princeofp.sh ;;
        Quake) ./scripts/games/quake.sh ;;
        ReturnC) ./scripts/games/rwolf.sh ;;
        Revolt) ./scripts/games/revolt.sh ;;
        SWarrior) ./scripts/games/swarrior.sh ;;
        SMario64) ./scripts/games/smario64.sh ;;
        SMarioWar) ./scripts/games/smariowar.sh ;;
        SpelunkyHD) ./scripts/games/spelunky.sh ;;
        Sqrxz4) ./scripts/games/sqrxz4.sh ;;
        Srb2) ./scripts/games/srb2.sh ;;
        SSam12) ./scripts/games/ssam.sh ;;
        StarCraft) ./scripts/games/starcraft.sh ;;
        StepMania) ./scripts/games/stepmania.sh ;;
        Temptations) ./scripts/games/temptations.sh ;;
        VVVVVV) ./scripts/games/vvvvvv.sh ;;
        Xump) ./scripts/games/xump.sh ;;
        esac
    done
}

smEmulators() {
    if is_userspace_64_bits; then
        show_dialog_only_32_bits "Amiga, Box86/64, Flycast, DOSBox, Mame, mGBA, PS1, PS2, RetroArch, Redream, ScummVM, VICE"
    fi
    cmd=(dialog --clear --backtitle "$TITLE" --title "[ Emulators ]" --menu "Select emulator from the list:" "$wHEIGHT" "$wWIDTH" "$wHEIGHT")

    options=(
        Back "Back to main menu"
        Amiga "Amiberry is the best Amiga emulator"
        Amstrad "Amstrad CPC with Caprice32"
        Box86-64 "Let's you run x86/64 Linux programs on non-x86/64 Linux"
        Dolphin "Dolphin is a Wii & Gamecube emulator (EXPERIMENTAL)"
        DOSBox "DOSBox-X is a DOS emulator with GUI"
        Flycast "Sega Dreamcast,Naomi,Naomi 2 and Atomiswave emu"
        Gba "Gameboy Advance (mgba)"
        Genesis "Genesis Megadrive Emulator (picodrive)"
        Mednafen "Portable multi-system emulator (Mednafen)"
        Mame "MAME is a multi-system emulator"
        MSX "OpenMSX"
        NES "Nestopia UE is an accurate NES emulator"
        Pifba "Emulates old arcade games using CPS1, CPS2,..."
        PS1 "DuckStation - PlayStation 1, aka. PSX Emulator"
        PS2 "AetherSX2 is an emulator of the PS Two console"
        PSP "PPSSPP can run your PSP games on your RPi in full HD resolution"
        ResidualVM "Cross-platform 3D game interpreter to play some games"
        RetroArch "Open source frontend for emulators & game/video engines"
        Redream "Redream is a Dreamcast emulator"
        ScummVM "Allow gamers to play point-and-click adventure games"
        Snes "SNES Emulator Snes9X or Bsnes"
        VICE "Commodore 64 emulator"
        ZX-Spectrum "Speccy is a ZX-Spectrum emulator"
    )

    choices=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)

    for choice in $choices; do
        case $choice in
        Back) break ;;
        Amiga) ./scripts/emus/amiga.sh ;;
        Box86-64) ./scripts/emus/box86_64.sh ;;
        Amstrad) ./scripts/emus/caprice.sh ;;
        Dolphin) ./scripts/emus/dolphin.sh ;;
        Flycast) ./scripts/emus/flycast.sh ;;
        DOSBox) ./scripts/emus/msdos.sh ;;
        Gba) ./scripts/emus/gba.sh ;;
        Genesis) ./scripts/emus/genesis.sh ;;
        Mednafen) ./scripts/emus/mednafen.sh ;;
        Mame) ./scripts/emus/mame.sh ;;
        MSX) ./scripts/emus/msx.sh ;;
        NES) ./scripts/emus/nes.sh ;;
        PS1) ./scripts/emus/psx.sh ;;
        PS2) ./scripts/emus/ps2.sh ;;
        PSP) ./scripts/emus/psp.sh ;;
        Pifba) ./scripts/emus/pifba.sh ;;
        ResidualVM) ./scripts/emus/residual.sh ;;
        RetroArch) ./scripts/emus/retroarch.sh ;;
        Redream) ./scripts/emus/redream.sh ;;
        ScummVM) ./scripts/emus/scummvm.sh ;;
        Snes) ./scripts/emus/snes.sh ;;
        VICE) ./scripts/emus/commodore.sh ;;
        ZX-Spectrum) ./scripts/emus/speccy.sh ;;
        esac
    done
}

smMultimedia() {
    if is_userspace_64_bits; then
        show_dialog_only_32_bits "OBS"
    fi
    cmd=(dialog --clear --backtitle "$TITLE" --title "[ Multimedia ]" --menu "Select a script from the list:" "$wHEIGHT" "$wWIDTH" "$wHEIGHT")

    options=(
        Back "Back to main menu"
        JELLYFIN "Stream media to any device from your own server"
        Kodi "Kodi is a free media player that is designed to look great on your TV but is just as home on a small screen."
        Kiosk "Image slideshow"
        Moonlight "Moonlight PC is an open source implementation of NVIDIA's GameStream"
        TV "CLI TV Player: Spain and International"
        OBS "Free & open source software 4 video recording and streaming"
    )

    choices=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)

    for choice in $choices; do
        case $choice in
        Back) break ;;
        JELLYFIN) ./scripts/mmedia/jellyfin.sh ;;
        Kodi) ./scripts/mmedia/xbmc.sh ;;
        Kiosk) ./scripts/mmedia/kiosk.sh ;;
        Moonlight) ./scripts/mmedia/moonlight-qt.sh ;;
        TV) ./scripts/mmedia/tvplayer.sh ;;
        OBS) ./scripts/mmedia/obs.sh ;;
        esac
    done
}

smConfigure() {
    cmd=(dialog --clear --backtitle "$TITLE" --title "[ Configure ]" --menu "Select to configure your distro:" "$wHEIGHT" "$wWIDTH" "$wHEIGHT")

    options=(
        Back "Back to main menu"
        Vulkan "Compile/update Vulkan Mesa driver"
        SSIDCfg "Configure SSID (WPA/WPA2 with PSK)"
        Joypad "Configure WII, XBox360 controller"
        Backup "Simple backup dir to run daily"
        # Applekeyb "Bluetooth keyboard"
        Netcfg "Configure static IP"
        Monitorcfg "Configure your TV resolution"
    )

    choices=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)

    for choice in $choices; do
        case $choice in
        Back) break ;;
        Vulkan) ./scripts/config/vulkan.sh ;;
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

    options=(
        Back "Back to main menu"
        Plowshare "Direct download from hosters like uploaded,..."
        SyncTERM "BBS terminal program"
        nChat "Use WhatsApp/Telegram on Terminal"
        Zoom "i386 version of software platform used for teleconferencing using Box86"
    )

    choices=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)

    for choice in $choices; do
        case $choice in
        Back) break ;;
        Plowshare) ./scripts/inet/ddown.sh ;;
        SyncTERM) ./scripts/inet/syncterm.sh ;;
        nChat) ./scripts/inet/nchat.sh ;;
        Zoom) ./scripts/inet/zoom.sh ;;
        esac
    done
}

smServer() {
    cmd=(dialog --clear --backtitle "$TITLE" --title "[ Server ]" --menu "Select to configure your distro as a server:" "$wHEIGHT" "$wWIDTH" "$wHEIGHT")

    options=(
        Back "Back to main menu"
        AdBlock "Turn Raspberry Pi into an Ad blocker with Pi-Hole"
        BlockIPs "Block access attempts to your Pi connected to the Internet"
        Cups "Printer server (cups)"
        DB "Install MariaDB"
        FTP "Simple FTP Server with vsftpd"
        FWork "WordPress, Node.js among others"
        GitServer "Use your RPi as a Git Server"
        Jenkins "Jenkins is a free and open source automation server"
        LEMP "Stack stands for Linux+NGinx+MariaDB+PHP"
        Minidlna "Install/Compile UPnP/DLNA Minidlna"
        Nagios "Nagios is a network host and service monitoring"
        OctoPrint "Control your 3D-Printer"
        RDesktop "Connect to your Raspberry Pi throught VNC,..."
        Smtp "SMTP Config to send e-mail"
        SMB "Share files with SAMBA"
        Upd "keep Debian patched with latest security updates"
        VPNServer "OpenVPN setup and config thanks to pivpn.io"
        Web "Web server"
        WebDAV "WebDAV to share local content with Apache"
    )

    choices=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)

    for choice in $choices; do
        case $choice in
        Back) break ;;
        AdBlock) ./scripts/server/adblock.sh ;;
        BlockIPs) sudo ./scripts/server/block-ips.sh ;;
        Cups) ./scripts/server/printer.sh ;;
        DB) ./scripts/server/db.sh ;;
        FTP) ./scripts/server/ftp.sh ;;
        FWork) ./scripts/server/fwork.sh ;;
        GitServer) ./scripts/server/gitserver.sh ;;
        Jenkins) ./scripts/server/jenkins.sh ;;
        LEMP) ./scripts/server/lemp.sh ;;
        Minidlna) ./scripts/server/mediaserver.sh ;;
        Nagios) ./scripts/server/nagios.sh ;;
        OctoPrint) ./scripts/server/octoprint.sh ;;
        RDesktop) ./scripts/server/rdesktop.sh ;;
        Smtp) ./scripts/server/smtp.sh ;;
        SMB) ./scripts/server/fileserver.sh ;;
        Upd) ./scripts/server/auto-upd.sh ;;
        VPNServer) ./scripts/server/openvpn.sh ;;
        Web) ./scripts/server/web.sh ;;
        WebDAV) ./scripts/server/webdav.sh ;;
        esac
    done
}

smDevs() {
    cmd=(dialog --clear --backtitle "$TITLE" --title "[ Developers ]" --menu "Select to configure some apps for development:" "$wHEIGHT" "$wWIDTH" "$wHEIGHT")

    options=(
        Back "Back to main menu"
        QT5 "Free and open-source widget toolkit for creating graphical UI cross-platform applications"
        TIC80 "TIC-80 is a free fantasy computer for making, playing tiny games"
        VSCode/ium "Lightweight but powerful source code editor which runs on your desktop"
    )

    choices=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)

    for choice in $choices; do
        case $choice in
        Back) break ;;
        QT5) ./scripts/devs/qt5.sh ;;
        TIC80) ./scripts/devs/tic-80.sh ;;
        VSCode/ium) ./scripts/devs/vscode.sh ;;
        esac
    done
}

smOthers() {
    cmd=(dialog --clear --backtitle "$TITLE" --title "[ Others ]" --menu "Another scripts uncategorized:" "$wHEIGHT" "$wWIDTH" "$wHEIGHT")

    options=(
        Back "Back to main menu"
        Aircrack "Compile Aircrack-NG suite easily"
        Alacritty "Fastest terminal emulator using GPU for rendering and Wayland compatible"
        BootLoader "Update your RPi boot loader"
        Fixes "Fix some problems with the Raspberry Pi OS"
        GL4ES "Compile GL4ES - OpenGL for GLES Hardware"
        NetTools "MITM Pentesting Opensource Toolkit (Require X)"
        Part "Check issues & fix SD corruptions"
        RPiPlay "An open-source implementation of an AirPlay mirroring server"
        Scrcpy "Display and control of Android devices connected on USB"
        SDL2 "Compile/Install SDL2 + Libraries"
        ShaderToy "Render over 100+ OpenGL ES 3.0 shaders"
        Synergy "Allow you to share keyboard and mouse to computers on LAN"
        Uninstall "Uninstall PiKISS :_("
        WineX86 "Install Wine X86 + Box86"
        Zsh "Install Z Shell"
    )

    choices=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)

    for choice in $choices; do
        case $choice in
        Back) break ;;
        Aircrack) ./scripts/others/aircrack.sh ;;
        Alacritty) ./scripts/others/alacritty.sh ;;
        BootLoader) ./scripts/others/update-bootloader.sh ;;
        Fixes) ./scripts/others/fixes.sh ;;
        GL4ES) ./scripts/others/gl4es.sh ;;
        NetTools) ./scripts/others/nettools.sh ;;
        Part) ./scripts/others/checkpart.sh ;;
        RPiPlay) ./scripts/others/rpiplay.sh ;;
        Scrcpy) ./scripts/others/scrcpy.sh ;;
        SDL2) ./scripts/others/sdl2.sh ;;
        ShaderToy) ./scripts/others/shadertoy.sh ;;
        Synergy) ./scripts/others/synergy.sh ;;
        Uninstall) uninstall_pikiss ;;
        WineX86) ./scripts/others/wine86.sh ;;
        Zsh) ./scripts/others/zsh.sh ;;
        esac
    done
}

show_dialog_only_32_bits() {
    local MESSAGE="This section has partial 64 Bits support.\nScripts availables: $1."

    if [[ -z "$1" ]]; then
        MESSAGE='Apologies!. PiKISS only works on 32 Bits OS.\n64 Bits support in progress...'
    fi

    dialog --title "[ 64 BITS OS DETECTED! ]" --msgbox "$MESSAGE" 8 52
}

#
# Main menu
#
while true; do
    cmd=(dialog --clear --backtitle "$TITLE" --title " [ M A I N - M E N U ] " --menu "You can use the UP/DOWN arrow keys, the first letter of the choice as a hot key, or the number keys 1-9 to choose an option:" "$wHEIGHT" "$wWIDTH" "$wHEIGHT")

    options=(
        Tweaks "Push your distro to the limit"
        Games "Install games easily"
        Emulation "Install emulators"
        Info "Info about the Pi or related"
        Multimedia "Install apps like XBMC"
        Configure "Installations are piece of cake now"
        Internet "Tweaks related to internet"
        Server "Use your distro as a server"
        Devs "Tools for making your own apps"
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
