#!/bin/bash
#
# Description : Testing overclock stability
# Author      : raspberrypi.org
#
clear

echo -e "Testing overclock stability...\n==============================\n\n· Simple stress test for system.\n· If survives to this, it's probably stable."

#Max out the CPU in the background (one core). Heats it up, loads the power-supply. 
nice yes >/dev/null &

#Read the entire SD card 10x. Tests RAM and I/O
for i in `seq 1 10`; do echo reading: $i; sudo dd if=/dev/mmcblk0 of=/dev/null bs=4M; done

#Writes 512 MB test file, 10x.
for i in `seq 1 10`; do echo writing: $i; dd if=/dev/zero of=deleteme.dat bs=1M count=512; sync; done

#Clean up
killall yes
rm deleteme.dat

#Print summary. Anything nasty will appear in dmesg.
echo -n "CPU freq: " ; cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_cur_freq
echo -n "CPU temp: " ; cat /sys/class/thermal/thermal_zone0/temp
dmesg | tail 

echo "Not crashed yet, probably stable."