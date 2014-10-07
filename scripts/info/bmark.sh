#!/bin/bash
#
# Description : Benchmark
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 1.0 (7/Oct/14)
#
# IMPROVEMENT : Test SD: dd if=/dev/zero of=/tmp/salida bs=1M count=300
# 
# More Info   : NBench -> http://www.tux.org/~mayer/linux/bmark.html
# 				Tinymembench -> https://github.com/ssvb/tinymembench
#
clear

PATH=$PATH:./bin && export PATH
INPUT=/tmp/mnu.sh.$$

trap "rm $INPUT; exit" SIGHUP SIGINT SIGTERM

while true
do
    dialog --clear --title "[ BENCHMARKS ]" \
    --menu "It can take 5-10 minutes. You can use the UP/DOWN arrow keys, the first letter of the choice as a hot key, or the number keys to choose an option.\nChoose A Benchmark:" 11 80 11 \
    Nbench "Expose the capabilities of a system's CPU, FPU & mem. sys." \
    Tinymembench "Simple memory benchmark program" \
    Exit "Exit to the shell" 2>"${INPUT}"
    menuitem=$(<"${INPUT}")

    case $menuitem in
        Nbench) nbench;;
        Tinymembench) tinymembench;;
        Exit) echo -e "\nBye"; break;;
    esac

done

read -p "Press [Enter] to continue..."