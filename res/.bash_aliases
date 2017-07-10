#!/bin/bash

#Add on .bashrc: source $HOME/.bashrc_aliases

# Stop bash from caching duplicate lines.
HISTCONTROL=ignoredups

alias cls='clear'
alias syslog='sudo tail -100f /var/log/syslog'
alias messages='sudo tail -100f /var/log/messages'
alias df='df -h'
alias path='echo -e ${PATH//:/\\n}'
alias upd='sudo apt-get update'
alias upgrade='sudo apt-get update && sudo apt-get dist-upgrade && sudo apt-get autoremove'
alias apt-search='apt-cache search'
alias apt-i='sudo apt install'
alias apt-iy='sudo apt install -y'
alias ll="ls --color -lAGbh --time-style='+%d %b %Y %H:%M'"
alias god='sudo -i'
alias cd='cdls'
alias rm='rm -rf'

# perform 'ls' after 'cd' if successful.
find() { find . -name  "$@" ; }

cdls() {
  builtin cd "$*"
  RESULT=$?
  if [ "$RESULT" -eq 0 ]; then
    ls
  fi
}
