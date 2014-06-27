#! /bin/bash
#
# Description : Streaming online TV channels thanks to http://www.tvenlinux.com/
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 0.7 (11/Jun/14)
#
# HELP        · http://pclosmag.com/html/issues/201104/page19.html
#
# Unfinished script...
#
clear

CHANNEL='RTVE1'
PLAYER='mplayer'

if [! -e /usr/bin/rtmpdump ]; then
    echo -e " \e[00;31mInstalling rtmpdump.\e[00m\n"
    sudo apt-get install -y rtmpdump
fi

if [ -e /tmp/livevideo ]; then rm /tmp/livevideo; fi

echo -p "Loading channel RTVE1, please wait 5 sec...\nWhen you finish, press [CTRL-C] to finish."

declare -a channelName=(
                        'RTVE1'
                        'La Sexta'
)

declare -a channelDescr=(
                        'Canal RTVE1 (ES)'
                        'Canal La Sexta (ES)'
)

declare -a streamChannel=(
                        'rtmp://rtvefs.fplive.net:1935/rtve-live-live?ovpfv=2.1.2/RTVE_LA1_LV3_WEB_NOG -W http://www.irtve.es/swf/4.2.15/RTVEPlayerVideo.swf'
                        'rtmp://live3.flashstreaming.mobi/live?token=2qwPJ0s-KwJfZ1V5N-rZ-AExpired=1390857763 -a live?token=2qwPJ0s-KwJfZ1V5N-rZ-AExpired=1390857763 -f LNX 11,2,202,332 -W http://flashstreaming.mobi/embed/noreproductor.php?o=1&kpublica=29245 -p http://flashstreaming.mobi -y divin3ef815416f775098fe977004015c6193'
)

i=0
while [ $i -lt ${#channelName[*]} ]; do
    if [ "${channelName[$i]}" = "$CHANNEL" ]; then
        mkfifo /tmp/livevideo
        (rtmpdump  -m 200 -r ${streamChannel[$i]} --live -q -o /tmp/livevideo | "$PLAYER" /tmp/livevideo)
#(rtmpdump  -m 200 -r rtmp://antena3fms35livefs.fplive.net:1935/antena3fms35live-live -y stream-antena3_1 -W http://www.antena3.com/static/swf/A3Player.swf?nocache=200 -p http://www.antena3.com/directo/ --live -q -o /tmp/livevideo | mplayer /tmp/livevideo)
        if [ -e /tmp/livevideo ]; then rm /tmp/livevideo; fi
    fi
    i=$(( $i + 1));
done
