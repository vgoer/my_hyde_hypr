#!/bin/bash

coords=$(slurp -d -b "#00000000" -c "#F4C6D1FF" -s "#00000044" -f "%x,%y,%w,%h")


if [ -z "$coords" ]; then
    exit 0
fi

IFS=',' read -r x y w h <<< "$coords"

# 直接在 exec 命令中指定浮动和位置
hyprctl dispatch exec "[float;move $x $y;size $w $h] kitty --class slurp-kitty"
