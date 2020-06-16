#!/bin/bash
#
# Description : Streaming TV Viewer. Thanks to Pikomule and tvenlinux
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 0.9 (6/Sep/14)
#
# HELP	      · https://dl.dropboxusercontent.com/s/al4x26cyp947kc1/PiKoMuLe.xml
# 	          · https://www.compraschinas.net/foro/livestreams/lista-de-canales-para-livestream-solo-plus-liga-y-gol-tv/
#             · https://www.enlacesiptv.es/2013/11/canal-espana-premium.html
#
# IMPROVEMENT · Read another xml stream file with different format
#             · Check whenever a var pageURL doen's exist
#             · On raspberry Pi, clean omxplayer front end
#
#
clear
#IFS=$'\n'
URL_FILE="https://dl.dropboxusercontent.com/s/al4x26cyp947kc1/PiKoMuLe.xml"
FREEMEM=$(free -m | sed -n 2p | awk '{print $3}')
[ -e /usr/bin/omxplayer ] && PLAYER="omxplayer -s -o hdmi " || PLAYER="mplayer -fs -framedrop "
INPUT=/tmp/mnu.sh.$$
trap "rm $INPUT; exit" SIGHUP SIGINT SIGTERM

[ ! -e /usr/bin/dialog ] && sudo apt-get install -y dialog
[ ! -e /usr/bin/rtmpdump ] && sudo apt-get install -y rtmpdump

validate_url(){
    if [[ `wget -S --spider $1 2>&1 | grep 'HTTP/1.1 200 OK'` ]]; then echo "true"; fi
}

if [[ ! -e ./PiKoMuLe.xml ]]; then
    dialog --infobox "Downloading streaming file..." 3 33; sleep 2

    if ! ping -q -w 1 -c 1 `ip r | grep default | cut -d ' ' -f 3` > /dev/null;then echo "Internet connection required. Check your network."; exit 1; fi

    if [[ $(validate_url $URL_FILE) != "true" ]] ; then
        clear
        echo "Sorry, not exist the .xml file and the file $URL_FILE has no longer accessible. Please download it manually."; exit 1
    else
        wget -q $URL_FILE
    fi
fi

(cat PiKoMuLe.xml | grep -e '<title>' | sed -e '/Actualizado\|\[COLOR/d' | sed 's/<[^>]*>//g' | sed '1d' | awk '{print "\""$0"\""}' | nl -b a | tr '\n\r' ' ') > /tmp/chntitles

stream(){
    STREAM=$(cat PiKoMuLe.xml | sed -e '/<link>_<\/link>\|XBMC/d' | grep -e '<link>' | sed 's/<[^>]*>//g' | sed $1'q;d')

    if [[ ($STREAM = *m3u8*) || ($STREAM = *mp4*) ]]; then
        $PLAYER $STREAM
    elif [[ $STREAM == *rtmp* ]]; then
        [ -e /tmp/livevideo ] && rm /tmp/livevideo
        mkfifo /tmp/livevideo

        rtmp=$(echo $STREAM | sed -n 's/^.*\(rtmp[^ ]*\).*/\1/p')
        playpath=$(echo $STREAM | sed -n 's/^.*\(playpath[^ ]*\).*/\1/p' | sed 's/playpath=//')
        swfUrl=$(echo $STREAM | sed -n 's/^.*\(swfUrl[^ ]*\).*/\1/p' | sed 's/swfUrl=//')
        pageUrl=$(echo $STREAM | sed -n 's/^.*\(pageUrl[^ ]*\).*/\1/p' | sed 's/pageUrl=//')

        (rtmpdump -r "${rtmp}" -y "${playpath}" -W "${swfUrl}" -p "${pageUrl}" --live -q -o /tmp/livevideo|$PLAYER /tmp/livevideo)

        [ -e /tmp/livevideo ] && rm /tmp/livevideo
    else
        dialog --title "Message" --clear \
            --msgbox "Not a valid channel. Please choose another or [ESC] to exit." 10 41

        case $? in
          0)
            echo "OK";;
          255)
            echo "ESC pressed.";;
        esac
    fi
}

while true
do
    dialog --clear --title "[ Stream TV ]" \
    --menu "Choose a channel, [ESC] twice to exit:" 15 50 4 --file /tmp/chntitles 2>"${INPUT}"

    case $? in
    0)
        stream $(<"${INPUT}") ;;
    255)
        clear; echo "ESC pressed. Have a nice day :)"; break ;;
    esac
done

# Cleaning the house
rm /tmp/chntitles $INPUT
# Kill all tvplayer process
$(ps -ef | awk '/tvplayer/{print $2}' | xargs kill -9) > /dev/null
