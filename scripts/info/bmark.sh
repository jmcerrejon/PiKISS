#!/bin/bash
#
# Description : Benchmark
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 1.0 (14/May/14)
#
# IMPROVEMENT : Test SD: dd if=/dev/zero of=/tmp/salida bs=1M count=300
#
clear

PATH=$PATH:./bin && export PATH

echo "Benchmark using nbench"
echo "======================"
echo -e "More Info: http://www.tux.org/~mayer/linux/bmark.html\nNOTE: It can take 5-10 minutes.\n"

while true; do
    read -p "Continue? [y/n] " yn
    case $yn in
    [Yy]* ) nbench;;
    [Nn]* ) exit;;
    * ) echo "Please answer (y)es, (n)o.";;
    esac
done

read -p "Press [Enter] to continue..."