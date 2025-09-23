#!/bin/bash
area=$(slurp -d -b "#00000000" -c "#F4C6D1FF" -s "#00000044" -f "%x,%y,%w,%h")

IFS=',' read x y w h <<< "$area"

notify-send "屏幕标尺" "宽度: ${w}px 高度: ${h}px\n位置: X${x}, Y${y}"