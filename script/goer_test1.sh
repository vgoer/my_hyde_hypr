#!/bin/bash

area=$(slurp -d -b "#00000000" -c "#F4C6D1FF" -s "#00000044" -f "%x,%y,%w,%h")


if [ -z "$area" ]; then
    exit 0
fi

IFS=',' read x y w h <<< "$area"

particle_x=$((x + RANDOM % 100 - 50))
particle_y=$((y + RANDOM % 100 - 50))

# 直接在 exec 命令中指定浮动和位置
hyprctl dispatch exec "[float;move $x $y;size $w $h] kitty --class slurp-kitty -e fireworkrs --position ${particle_x}x${particle_y} -e cat"
