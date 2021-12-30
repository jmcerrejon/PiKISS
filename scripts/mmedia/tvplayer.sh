#!/bin/bash
#
# Description : TV Channels Viewer.
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 1.0.0 (30/Dec/21)
#
# Help        : https://jqplay.org/
#
. ./scripts/helper.sh || . ../helper.sh || . ./helper.sh || wget -q 'https://github.com/jmcerrejon/PiKISS/raw/master/scripts/helper.sh'
clear
check_board || { echo "Missing file helper.sh. I've tried to download it for you. Try to run the script again." && exit 1; }

readonly CHANNELS_JSON_URL="https://www.tdtchannels.com/lists/tv.json"
FREEMEM="$(get_free_mem)"
JSON_FILE=/tmp/tv.json.$$
INPUT_COUNTRY=/tmp/mnu_opt_country.$$
COUNTRIES_PATH=/tmp/countries.$$
AMBITS_PATH=/tmp/ambits.$$
CHANNELS_PATH=/tmp/channels.$$
OPTIONS_PATH=/tmp/options.$$

download_channel_list() {
    echo "Downloading channel list..."
    wget -qO "$JSON_FILE" "$CHANNELS_JSON_URL"
}

delete_temporal_files() {
    [[ -e $JSON_FILE ]] && rm "$JSON_FILE"
    [[ -e $INPUT_COUNTRY ]] && rm "$INPUT_COUNTRY"
    [[ -e $COUNTRIES_PATH ]] && rm "$COUNTRIES_PATH"
    [[ -e $AMBITS_PATH ]] && rm "$AMBITS_PATH"
    [[ -e $CHANNELS_PATH ]] && rm "$CHANNELS_PATH"
    [[ -e $OPTIONS_PATH ]] && rm "$OPTIONS_PATH"
    [[ -e $INPUT_OPTION ]] && rm "$INPUT_OPTION"
}

clean_file() {
    echo "" >"$1"
}

add_back_option() {
    clean_file "$1"
    echo "B Back" >>"$1"
}

save_countries_file() {
    local INDEX=0

    echo "" >"$COUNTRIES_PATH"

    jq <"$JSON_FILE" '.countries | .[].name' | while read p; do
        echo "$INDEX $p" >>"$COUNTRIES_PATH"
        INDEX=$((INDEX + 1))
    done
}

save_ambits_file() {
    local INDEX=0

    add_back_option "$AMBITS_PATH"
    jq <"$JSON_FILE" ".countries | .[$1].ambits[].name" | while read p; do
        echo "$INDEX $p" >>"$AMBITS_PATH"
        INDEX=$((INDEX + 1))
    done
}

save_channels_file() {
    local INDEX=0

    add_back_option "$CHANNELS_PATH"
    jq <"$JSON_FILE" ".countries | .[$1].ambits[$2].channels[].name" | while read p; do
        echo "$INDEX $p" >>"$CHANNELS_PATH"
        INDEX=$((INDEX + 1))
    done
}

save_options_file() {
    local INDEX=0

    add_back_option "$OPTIONS_PATH"
    jq <"$JSON_FILE" ".countries | .[$1].ambits[$2].channels[$3].options[$4].url" | while read p; do
        echo "$INDEX $p" >>"$OPTIONS_PATH"
        INDEX=$((INDEX + 1))
    done
}

check_options() {
    if jq <"$JSON_FILE" ".countries | .[$1].ambits[$2].channels[$3].options==[]" | grep -q true; then
        echo "This channel has not stream. Opening the browser with the channel..."
        WEB_URL=$(jq <"$JSON_FILE" ".countries | .[$1].ambits[$2].channels[$3].web" | sed 's/^"//' | sed 's/"$//')
        open_default_browser "$WEB_URL"
        channel_menu "$1" "$2"
    fi

    if jq <"$JSON_FILE" ".countries | .[$1].ambits[$2].channels[$3].options | length" | grep -q 1; then
        open_stream "$1" "$2" "$3" "0"
        channel_menu "$1" "$2"
    fi

    save_options_file "$1" "$2" "$3"
    options_menu "$1" "$2" "$3"
}

open_stream() {
    STREAM_URL=$(jq <"$JSON_FILE" ".countries | .[$1].ambits[$2].channels[$3].options[$4].url" | sed 's/^"//' | sed 's/"$//')
    play_media "$STREAM_URL"
}

#
# Menus
#

main_menu() {
    save_countries_file

    while true; do
        dialog --clear --title "[ Stream TV Channels .:. Free Memory: $FREEMEM ]" \
            --menu "Choose a provider, [ESC] twice to exit:" 15 50 4 --file "$COUNTRIES_PATH" 2>"${INPUT_COUNTRY}"

        case $? in
        0)
            save_ambits_file "$(<"${INPUT_COUNTRY}")"
            ambit_menu "$(<"${INPUT_COUNTRY}")"
            break
            ;;
        255)
            clear
            echo "ESC pressed. Have a nice day :)"
            break
            ;;
        esac
    done
}

ambit_menu() {
    CMD=(dialog --clear --title "[ Ambits ]"
        --menu "Choose an ambit, [ESC] twice to exit:" 15 50 4 --file "$AMBITS_PATH")

    CHOICES=$("${CMD[@]}" 2>&1 >/dev/tty)

    for CHOICE in $CHOICES; do
        case $CHOICE in
        B)
            main_menu
            break
            ;;
        255)
            clear
            echo "ESC pressed. Have a nice day :)"
            break
            ;;
        *)
            save_channels_file "$1" "$CHOICE"
            channel_menu "$1" "$CHOICE"
            break
            ;;
        esac
    done
}

channel_menu() {
    CMD=(dialog --clear --title "[ Channels ]"
        --menu "Choose a channel, [ESC] twice to exit:" 15 50 4 --file "$CHANNELS_PATH")

    CHOICES=$("${CMD[@]}" 2>&1 >/dev/tty)

    for CHOICE in $CHOICES; do
        case $CHOICE in
        B)
            ambit_menu
            break
            ;;
        255)
            clear
            echo "ESC pressed. Have a nice day :)"
            break
            ;;
        *)
            check_options "$1" "$2" "$CHOICE"
            break
            ;;
        esac
    done
}

options_menu() {
    CMD=(dialog --clear --title "[ Streams ]"
        --menu "Choose a stream, [ESC] twice to exit:" 15 50 4 --file "$OPTIONS_PATH")

    CHOICES=$("${CMD[@]}" 2>&1 >/dev/tty)

    for CHOICE in $CHOICES; do
        case $CHOICE in
        B)
            channel_menu "$1" "$2"
            break
            ;;
        255)
            clear
            echo "ESC pressed. Have a nice day :)"
            break
            ;;
        *)
            open_stream "$1" "$2" "$3" "$CHOICE"
            channel_menu "$1" "$2"
            break
            ;;
        esac
    done
}

download_channel_list
main_menu
delete_temporal_files
