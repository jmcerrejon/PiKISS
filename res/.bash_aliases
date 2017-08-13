#!/usr/bin/env bash

#Add on .bashrc:
# if [ -f ~/.bash_aliases ]; then
# . ~/.bash_aliases
# fi

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
alias free='free -m'
alias part='lsblk'
alias path='echo -e ${PATH//:/\\n}'
alias upd='sudo apt-get update'
alias upgrade='sudo apt-get update && sudo apt-get dist-upgrade && sudo apt-get autoremove'
alias apts='apt-cache search'
alias aptsv='apt-cache madison'
alias apti='sudo apt install'
alias aptiy='sudo apt install -y'
alias ll="ls --color -lAGbh --group-directories-first --time-style='+%d %b %Y %H:%M'"
alias god='sudo -i'
alias rmr='rm -rf'
alias shutd='sudo shutdown -P now'
alias reboot='sudo shutdown -r now'
alias p='ps aux |grep'
alias n='nano'
alias nanosources='sudo nano /etc/apt/sources.list'
alias nanofstab='sudo nano /etc/fstab'
alias !='sudo'
alias pk='cd /home/pi/sc/piKiss/ && ./piKiss.sh'

# Functions

mk() {
  mkdir $1 && cd $_ || exit
}

search() {
  sudo find / -iname *"$1"*
}

ex () {
  if [ -f $1 ] ; then
      case $1 in
        *.tar.bz2 | *.tbz2) tar xvjf $1   ;;
        *.tar.gz | *.tgz)   tar xvzf $1   ;;
        *.bz2)              tar jxf $1    ;;
        *.rar)              unrar x $1    ;;
        *.gz)               gunzip $1     ;;
        *.tar)              tar xvf $1    ;;
        *.zip)              unzip $1      ;;
        *.Z)                uncompress $1 ;;
        *.7z)               7z x $1       ;;
        *.exe)              cabextract $1 ;;
        *)                  echo "'$1': unrecognized file compression" ;;
      esac
  else
      echo "'$1' is not a valid file"
  fi
}
