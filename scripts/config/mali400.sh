#!/bin/bash
#
# Description : Mali400 GPU Hardware Acceleration for Banana Pi
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 0.3 (15/01/15)
#
# HELP 		  : mplayer -nosound -vo fbdev 1080.mp4
# 				Dependencies to omxplayer: apt-get install fonts-freefont-ttf dbus libssh-4 -y
#
clear

cd $HOME
X11=0
ON_BOOT=0

echo -e "Mali400 GPU Hardware Acceleration for Banana Pi\n===============================================\n\n·Make sure you enable video acceleration with 'bananian-config'.\n· This script help you to config the libraries sunxi-mali with libUMP, vdpau and mplayer.\n"

read -p "Continue? (y/n)" option
case "$option" in
    n*) exit ;;
esac

clear
echo -e "Please, answer a few questions...\n\n"

read -p "Will you use X11? (y/n)" option
case "$option" in
    n*) $X11=1 ;;
esac

read -p "Do you want to load HW Acceleration modules on boot? (y/n)" option
case "$option" in
    n*) $ON_BOOT=1 ;;
esac

echo -e "Installing dependencies...\n"
apt-get update && apt-get -y install git build-essential autoconf libtool automake libvdpau-dev pkg-config

echo -e "Installing UMP (Unified Memory Provider)...\n"
git clone https://github.com/linux-sunxi/libump.git
cd libump
autoreconf -i
./configure
make
make install
cp /usr/local/lib/libUMP.so.3 /usr/lib/libUMP.so.3
cd $HOME

echo -e "Installing Mali userspace driver...\n"
cd sunxi-mali
make config && make install
cd $HOME

echo -e "Installing VDPAU...\n"
git clone --depth 1 https://github.com/linux-sunxi/libvdpau-sunxi
cd libvdpau-sunxi
make
make install

# Create rules
echo 'KERNEL=="disp", MODE="0660", GROUP="video"' > /etc/udev/rules.d/50-disp.rules
echo 'KERNEL=="cedar_dev", MODE="0660", GROUP="video"' > /etc/udev/rules.d/50-cedar.rules
echo 'KERNEL=="g2d", MODE="0660", GROUP="video"' > /etc/udev/rules.d/50-g2d.rules 

echo -e "Installing mplayer2...\n"
apt-get install -y libavcodec-extra-53 mplayer2
mkdir /etc/mplayer
cat <<'EOT' > /etc/mplayer/mplayer.conf
vo=vdpau,
vc=ffmpeg12vdpau,ffh264vdpau,
fullscreen=yes
quiet=yes
ao=pulse
framedrop=yes
cache=8192
lavdopts=threads=2
ass=no
ass-font-scale=1.4
ass-color=FFFFFF00
ass-border-color=00000000
ass-use-margins=yes
ass-bottom-margin=50
spualign=2
subalign=2
subfont=/usr/share/fonts/truetype/ttf-dejavu/DejaVuSans.ttf
subcp=cp1250
EOT

if [ $ON_BOOT -eq 1 ]; then
	cat <<'EOT' >> /etc/modules
# GPU drivers
ump
drm
mali
mali_drm
sunxi_cedar_mod

# CPU modules
cpufreq_stats
cpufreq_userspace
cpufreq_conservative
cpufreq_powersave
EOT

fi

if [ $X11 -eq 1 ]; then
	cat <<'EOT' >> /etc/environment
DISPLAY=:0
VDPAU_DRIVER=sunxi
VDPAU_OSD=1
EOT
fi