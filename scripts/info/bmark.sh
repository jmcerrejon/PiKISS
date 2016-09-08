#!/bin/bash
#
# Description : Benchmark
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 1.1 (09/Sep/16)
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

SD_Bmark(){
    clear

    echo -e "SD Benchmark (in MB/s)\n======================\n"
    echo -e "Please wait...\n"

    echo -e "\nWrite Speed (MB/s)\n"

    time dd bs=1M count=128 if=/dev/zero of=testdata conv=fdatasync # write speed
    sync && echo -n 3 | sudo tee /proc/sys/vm/drop_caches # flush cache

    echo -e "\nRead Speed (MB/s)\n"

    time dd bs=1M if=testdata of=/dev/null # read speed

    read -p "Press [Enter] to continue..."
}

while true
do
    dialog --clear --title "[ BENCHMARKS ]" \
    --menu "It can take 5-10 minutes. You can use the UP/DOWN arrow keys, the first letter of the choice as a hot key, or the number keys to choose an option.\nChoose A Benchmark:" 12 80 12 \
    Nbench "Expose the capabilities of a system's CPU, FPU & mem. sys." \
    Tinymembench "Simple memory benchmark program" \
    SDCard "SD read/write speed (need root access)" \
    Exit "Exit to the shell" 2>"${INPUT}"
    menuitem=$(<"${INPUT}")

    case $menuitem in
        Nbench) nbench; break;;
        Tinymembench) tinymembench; break;;
        SDCard) SD_Bmark; break;;
        Exit) echo -e "\nBye"; break;;
    esac

done

read -p "Press [Enter] to continue..."
