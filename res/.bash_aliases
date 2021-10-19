#!/usr/bin/env bash

# Stop bash from caching duplicate lines.
HISTCONTROL=ignoredups

alias c='clear'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias syslog='sudo tail -100f /var/log/syslog'
alias messages='sudo tail -100f /var/log/messages'
alias auth='sudo tail -100f /var/log/auth.log'
alias df='df -h'
alias du='du -h --max-depth=1'
alias free='free -m'
alias part='lsblk'
alias path='echo -e ${PATH//:/\\n}'
alias ll="ls --color -lAGbh --group-directories-first --time-style='+%d %b %Y %H:%M'"
alias god='sudo -i'
alias rmr='rm -rf'
alias shutd='sudo shutdown -P now'
alias reboot='sudo shutdown -r now'
alias restart='reboot'
alias p='ps aux |grep'
alias n='nano'
alias nanosources='sudo nano /etc/apt/sources.list'
alias nanofstab='sudo nano /etc/fstab'
alias pk='cd /home/pi/pikiss/ && ./piKiss.sh -nup'
alias 7zc='7z a -t7z -m0=lzma -mx=9 -mfb=64 -md=32m -ms=on file-rpi.7z'
alias mkfr='find ./ -print > files_required.txt'
alias open_ports='sudo ss -ltnp'

# APT
alias au='sudo apt-get -qq -y update'
alias ar='sudo apt -y autoremove && sudo apt autoclean'
alias aup='au && sudo apt -y dist-upgrade && ar'
alias afup='au && sudo apt -y full-upgrade && ar'
alias as='apt-cache search'
alias asv='apt-cache madison'
alias asf='apt-file search'
alias apiy='sudo apt install -y'
alias abdp='sudo apt-get build-dep'
alias dep='dpkg-depcheck -d ./configure' # Check dependencies from a source code dir using file ./configure

# Functions

ip() {
    hostname -I | awk '{print $1}'
}

is_installed() {
    sudo dpkg -l | grep "$1"
}

mk() {
    mkdir "$1" && cd "$_" || exit
}

my_checkinstall() {
    # Config at /etc/checkinstallrc
    sudo checkinstall --install=no --fstrans=yes -D --pkgname="$1" --pkgversion=1 --pkgrelease="1" --maintainer=ulysess@gmail.com --strip=no --stripso=no --addso=yes -d2 make
}

search() {
    sudo find / -iname *"$1"*
}

extract() {
    if [ -f "$1" ]; then
        case "$1" in
        *.tar.bz2 | *.tbz2) tar xjf "$1" ;;
        *.tar.gz | *.tgz) tar xzf "$1" ;;
        *.tar.xz) tar xf "$1" ;;
        *.xz) xz --decompress "$1" ;;
        *.bz2) tar jxf "$1" ;;
        *.rar) unrar x "$1" ;;
        *.gz) gunzip "$1" ;;
        *.tar) tar xvf "$1" ;;
        *.zip) unzip -qq -o "$1" ;;
        *.Z) uncompress "$1" ;;
        *.7z) p7zip -d "$1" ;;
        *.exe) cabextract "$1" ;;
        *) echo "'$1': unrecognized file compression" ;;
        esac
    else
        echo "'$1' is not a valid file"
    fi
}
