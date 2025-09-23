#!/bin/bash
# 脚本用法: change-layout.sh [master|dwindle|hy3|slidr]

# 通知图标路径
notif="$HOME/.config/cava/cava.png"

# 获取第一个参数作为目标布局
TARGET_LAYOUT=$1

# 检查参数是否为空
if [ -z "$TARGET_LAYOUT" ]; then
    echo "用法: $0 [master|dwindle|hy3|slidr|nstack|scrolling|river]"
    exit 1
fi

# 根据参数切换布局
case "$TARGET_LAYOUT" in
    "master")
        hyprctl keyword general:layout master
        hyprctl keyword unbind SUPER,J
        hyprctl keyword unbind SUPER,K
        hyprctl keyword unbind SUPER,O
        hyprctl keyword bind SUPER,J,layoutmsg,cyclenext
        hyprctl keyword bind SUPER,K,layoutmsg,cycleprev
        notify-send -e -u low -i "$notif" "Master Layout"
        ;;
    "dwindle")
        hyprctl keyword general:layout dwindle
        hyprctl keyword unbind SUPER,J
        hyprctl keyword unbind SUPER,K
        hyprctl keyword unbind SUPER,O
        hyprctl keyword bind SUPER,J,cyclenext
        hyprctl keyword bind SUPER,K,cyclenext,prev
        hyprctl keyword bind SUPER,O,togglesplit
        notify-send -e -u low -i "$notif" "Dwindle Layout"
        ;;
    "hy3")
        hyprctl keyword general:layout hy3
        hyprctl keyword unbind SUPER,J
        hyprctl keyword unbind SUPER,K
        hyprctl keyword unbind SUPER,O
        hyprctl keyword bind SUPER,J,cyclenext
        hyprctl keyword bind SUPER,K,cyclenext,prev
        hyprctl keyword bind SUPER,O,togglesplit
        notify-send -e -u low -i "$notif" "Hy3 Layout"
        ;;
    "nstack")
        hyprctl keyword general:layout nstack
        hyprctl keyword unbind SUPER,J
        hyprctl keyword unbind SUPER,K
        hyprctl keyword unbind SUPER,O
        hyprctl keyword bind SUPER,J,cyclenext
        hyprctl keyword bind SUPER,K,cyclenext,prev
        hyprctl keyword bind SUPER,O,togglesplit
        notify-send -e -u low -i "$notif" "Nstack Layout"
        ;;
    "scrolling")
        hyprctl keyword general:layout scrolling
        hyprctl keyword unbind SUPER,J
        hyprctl keyword unbind SUPER,K
        hyprctl keyword unbind SUPER,O
        hyprctl keyword bind SUPER,J,cyclenext
        hyprctl keyword bind SUPER,K,cyclenext,prev
        hyprctl keyword bind SUPER,O,togglesplit
        notify-send -e -u low -i "$notif" "Scrolling Layout"
		;;
    "river")
        hyprctl keyword general:layout river
        hyprctl keyword unbind SUPER,J
        hyprctl keyword unbind SUPER,K
        hyprctl keyword unbind SUPER,O
        hyprctl keyword bind SUPER,J,cyclenext
        hyprctl keyword bind SUPER,K,cyclenext,prev
        hyprctl keyword bind SUPER,O,togglesplit
        notify-send -e -u low -i "$notif" "River Layout"
		;;
esac

exit 0

# top
# hyprctl dispatch layoutmsg orientationtop  orientationleft orientationright  orientationbottom
#  orientationcenter orientationnext orientationprev  addmaster