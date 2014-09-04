#!/bin/bash
#
# Description : SD Benchmark
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 1.0 (4/Sep/14)
#
clear

echo -e "SD Benchmark\n============\n"
echo -e "Please wait...\n"

echo -e "\nWrite Speed (MB/s)\n"

time dd bs=1M count=128 if=/dev/zero of=testdata conv=fdatasync # write speed
sync && echo -n 3 | sudo tee /proc/sys/vm/drop_caches # flush cache

echo -e "\nRead Speed (MB/s)\n"

time dd bs=1M if=testdata of=/dev/null # read speed