#!/bin/bash

area=$(slurp -d -b "#00000000" -c "#F4C6D1FF" -s "#00000044" -f "%x,%y,%w,%h")

if [ -z "$area" ]; then
    exit 0
fi

IFS=',' read x y w h <<< "$area"

if [ $w -gt 500 ] && [ $h -gt 500 ]; then
    # cmatrix 按 q 退出
    hyprctl dispatch exec "[float;move $x $y;size $w $h] kitty --class slurp-kitty -e cmatrix -s"
elif [ $w -lt 100 ] && [ $h -lt 100 ]; then
    # asciiquarium 按 q 退出
    hyprctl dispatch exec "[float;move $x $y;size $w $h] kitty --class slurp-kitty -e asciiquarium"
else
    # 使用sh -c来正确解析管道符，按 q 退出
    hyprctl dispatch exec "[float;move $x $y;size $w $h] kitty --class slurp-kitty -e sh -c 'fortune | cowsay | lolcat; echo \"\"; echo \"按 q 退出...\"; while true; do read -n 1 key; if [[ \$key == \"q\" ]]; then break; fi; done'"
fi