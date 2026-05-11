#!/usr/bin/env bash

## Copyright (C) 2020-2023 Aditya Shakya <adi1090x@gmail.com>
## Edited for Garuda Linux by yurihikari

# Import Current Theme
DIR="$HOME/.config/hypr"
RASI="$DIR/rofi/music.rasi"


# 初始化hyde环境（如果可用）
[[ "${HYDE_SHELL_INIT}" -ne 1 ]] && eval "$(hyde-shell init)" 2>/dev/null || true


# Rofi配置
setup_rofi_config() {
    local font_scale="${ROFI_SEARCH_SCALE:-${ROFI_EMOJI_SCALE}}"
    [[ "${font_scale}" =~ ^[0-9]+$ ]] || font_scale=${ROFI_SCALE:-10}

    local font_name=${ROFI_SEARCH_FONT:-${ROFI_EMOJI_FONT:-$ROFI_FONT}}
    if command -v get_hyprConf >/dev/null 2>&1; then
        font_name=${font_name:-$(get_hyprConf "MENU_FONT" 2>/dev/null)}
        font_name=${font_name:-$(get_hyprConf "FONT" 2>/dev/null)}
    fi

    font_override="* {font: \"${font_name:-"JetBrainsMono Nerd Font"} ${font_scale}\";}"

    local hypr_border
    if command -v hyprctl >/dev/null && command -v jq >/dev/null; then
        hypr_border=$(hyprctl -j getoption decoration:rounding 2>/dev/null | jq -r '.int' 2>/dev/null || echo "0")
    else
        hypr_border=0
    fi
    
    local wind_border=$((hypr_border * 3 / 2))
    local elem_border=$((hypr_border == 0 ? 5 : hypr_border))

    local hypr_width
    if command -v hyprctl >/dev/null && command -v jq >/dev/null; then
        hypr_width=$(hyprctl -j getoption general:border_size 2>/dev/null | jq -r '.int' 2>/dev/null || echo "1")
    else
        hypr_width=1
    fi
    
    r_override="window{border:${hypr_width}px;border-radius:${wind_border}px;}listview{border-radius:${elem_border}px;} element{border-radius:${elem_border}px;}"
}

# Theme Elements
status="`mpc status`"
if [[ -z "$status" ]]; then
	prompt='Offline'
	mesg="MPD is Offline"
else
	prompt="`mpc -f "%artist%" current`"
	mesg="`mpc -f "%file%" current`"
fi

# Options
layout=`cat ${RASI} | grep 'USE_ICON' | cut -d'=' -f2`
if [[ "$layout" == 'NO' ]]; then
	if [[ ${status} == *"[playing]"* ]]; then
		option_1=" Pause"
	else
		option_1=" Play"
	fi
	option_2=" Stop"
	option_3=" Previous"
	option_4=" Next"
	option_5=" Repeat"
	option_6=" Random"
else
	if [[ ${status} == *"[playing]"* ]]; then
		option_1=""
	else
		option_1=""
	fi
	option_2=""
	option_3=""
	option_4=""
	option_5=""
	option_6=""
fi

# Toggle Actions
active=''
urgent=''
# Repeat
if [[ ${status} == *"repeat: on"* ]]; then
    active="-a 4"
elif [[ ${status} == *"repeat: off"* ]]; then
    urgent="-u 4"
else
    option_5=" Parsing Error"
fi
# Random
if [[ ${status} == *"random: on"* ]]; then
    [ -n "$active" ] && active+=",5" || active="-a 5"
elif [[ ${status} == *"random: off"* ]]; then
    [ -n "$urgent" ] && urgent+=",5" || urgent="-u 5"
else
    option_6=" Parsing Error"
fi

# Rofi CMD
rofi_cmd() {
	rofi -dmenu \
		-p "$prompt" \
		-mesg "$mesg" \
        -config "${ROFI_BOOKMARK_STYLE:-clipboard}" \
		${active} ${urgent} \
		-markup-rows \
		-theme ${RASI}
}

# Pass variables to rofi dmenu
run_rofi() {
	echo -e "$option_1\n$option_2\n$option_3\n$option_4\n$option_5\n$option_6" | rofi_cmd
}

# Execute Command
# iDIR="$HOME/.config/hypr/mako/icons"
iDIR="$HOME/.config/cava/cava.png"

notify_song="notify-send -h string:x-canonical-private-synchronous:sys-notify-song -u low -i ${iDIR}/music.png"
run_cmd() {
	if [[ "$1" == '--opt1' ]]; then
		mpc -q toggle && ${notify_song} "`mpc -f "%artist%" current`"
	elif [[ "$1" == '--opt2' ]]; then
		mpc -q stop
	elif [[ "$1" == '--opt3' ]]; then
		mpc -q pause && mpc -q prev && mpc -q start && ${notify_song} "`mpc -f "%artist%" current`"
	elif [[ "$1" == '--opt4' ]]; then
		mpc -q pause && mpc -q next && mpc -q start && ${notify_song} "`mpc -f "%artist%" current`"
	elif [[ "$1" == '--opt5' ]]; then
		mpc -q repeat
	elif [[ "$1" == '--opt6' ]]; then
		mpc -q random
	fi
}

# Actions
chosen="$(run_rofi)"
case ${chosen} in
    $option_1)
		run_cmd --opt1
        ;;
    $option_2)
		run_cmd --opt2
        ;;
    $option_3)
		run_cmd --opt3
        ;;
    $option_4)
		run_cmd --opt4
        ;;
    $option_5)
		run_cmd --opt5
        ;;
    $option_6)
		run_cmd --opt6
        ;;
esac