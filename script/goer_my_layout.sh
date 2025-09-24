#!/usr/bin/env bash

# 初始化hyde环境（如果可用）
[[ "${HYDE_SHELL_INIT}" -ne 1 ]] && eval "$(hyde-shell init)" 2>/dev/null || true

# 通知图标路径
notif="${HOME}/.config/cava/cava.png"

# 布局配置
declare -A LAYOUT_CONFIGS
LAYOUT_CONFIGS=(
    ["master"]="Master Layout"
    ["master-top"]="Master Top" 
    ["master-bottom"]="Master Bottom"
    ["master-left"]="Master Left"
    ["master-right"]="Master Right"
    ["master-center"]="Master Center"
    ["master-next"]="Master Next Orientation"
    ["master-prev"]="Master Prev Orientation"
    ["master-add-master"]="Master Add Master"
    ["master-remove-master"]="Master Remove Master"
    ["dwindle"]="Dwindle Layout"
    ["hy3"]="Hy3 Layout"
    ["nstack"]="Nstack Layout"
    ["scrolling"]="Scrolling Layout"
    ["river"]="River Layout"
)

# 布局对应的键位绑定
declare -A LAYOUT_BINDINGS
LAYOUT_BINDINGS=(
    ["master"]="SUPER,J,layoutmsg,cyclenext|SUPER,K,layoutmsg,cycleprev"
    ["master-top"]="SUPER,J,layoutmsg,cyclenext|SUPER,K,layoutmsg,cycleprev"
    ["master-bottom"]="SUPER,J,layoutmsg,cyclenext|SUPER,K,layoutmsg,cycleprev"
    ["master-left"]="SUPER,J,layoutmsg,cyclenext|SUPER,K,layoutmsg,cycleprev"
    ["master-right"]="SUPER,J,layoutmsg,cyclenext|SUPER,K,layoutmsg,cycleprev"
    ["master-center"]="SUPER,J,layoutmsg,cyclenext|SUPER,K,layoutmsg,cycleprev"
    ["master-next"]="SUPER,J,layoutmsg,cyclenext|SUPER,K,layoutmsg,cycleprev"
    ["master-prev"]="SUPER,J,layoutmsg,cyclenext|SUPER,K,layoutmsg,cycleprev"
    ["master-add-master"]="SUPER,J,layoutmsg,cyclenext|SUPER,K,layoutmsg,cycleprev"
    ["master-remove-master"]="SUPER,J,layoutmsg,cyclenext|SUPER,K,layoutmsg,cycleprev"
    ["dwindle"]="SUPER,J,cyclenext|SUPER,K,cyclenext,prev|SUPER,O,togglesplit"
    ["hy3"]="SUPER,J,cyclenext|SUPER,K,cyclenext,prev|SUPER,O,togglesplit"
    ["nstack"]="SUPER,J,cyclenext|SUPER,K,cyclenext,prev|SUPER,O,togglesplit"
    ["scrolling"]="SUPER,J,cyclenext|SUPER,K,cyclenext,prev|SUPER,O,togglesplit"
    ["river"]="SUPER,J,cyclenext|SUPER,K,cyclenext,prev|SUPER,O,togglesplit"
)

# Master布局方向命令
declare -A MASTER_ORIENTATION
MASTER_ORIENTATION=(
    ["master-top"]="orientationtop"
    ["master-bottom"]="orientationbottom"
    ["master-left"]="orientationleft"
    ["master-right"]="orientationright"
    ["master-center"]="orientationcenter"
    ["master-next"]="orientationnext"
    ["master-prev"]="orientationprev"
    ["master-add-master"]="addmaster"
    ["master-remove-master"]="removemaster"
)

# 清除旧绑定
clear_bindings() {
    hyprctl keyword unbind SUPER,J 2>/dev/null || true
    hyprctl keyword unbind SUPER,K 2>/dev/null || true
    hyprctl keyword unbind SUPER,O 2>/dev/null || true
}

# 应用新绑定
apply_bindings() {
    local layout="$1"
    local bindings="${LAYOUT_BINDINGS[$layout]}"
    
    IFS='|' read -ra BIND_ARRAY <<< "$bindings"
    for binding in "${BIND_ARRAY[@]}"; do
        if [[ -n "$binding" ]]; then
            hyprctl keyword bind $binding
        fi
    done
}

# 应用Master布局方向
apply_master_orientation() {
    local layout="$1"
    local orientation="${MASTER_ORIENTATION[$layout]}"
    
    if [[ -n "$orientation" ]]; then
        hyprctl dispatch layoutmsg "$orientation"
    fi
}

# 切换布局
switch_layout() {
    local target_layout="$1"
    
    if [[ -z "${LAYOUT_CONFIGS[$target_layout]}" ]]; then
        echo "错误: 不支持的布局 '$target_layout'"
        echo "可用布局: ${!LAYOUT_CONFIGS[@]}" | tr ' ' '\n' | sort
        exit 1
    fi
    
    # 设置主布局
    if [[ "$target_layout" == master* ]]; then
        hyprctl keyword general:layout master
        apply_master_orientation "$target_layout"
    else
        hyprctl keyword general:layout "$target_layout"
    fi
    
    # 更新键位绑定
    clear_bindings
    apply_bindings "$target_layout"
    
    # 发送通知
    notify-send -e -u low -i "$notif" "${LAYOUT_CONFIGS[$target_layout]}"
    echo "切换到布局: ${LAYOUT_CONFIGS[$target_layout]}"
}

# Rofi配置
setup_rofi_config() {
    local font_scale="${ROFI_EMOJI_SCALE}"
    [[ "${font_scale}" =~ ^[0-9]+$ ]] || font_scale=${ROFI_SCALE:-10}

    local font_name=${ROFI_EMOJI_FONT:-$ROFI_FONT}
    font_name=${font_name:-$(get_hyprConf "MENU_FONT")}
    font_name=${font_name:-$(get_hyprConf "FONT")}

    font_override="* {font: \"${font_name:-"JetBrainsMono Nerd Font"} ${font_scale}\";}"

    local hypr_border=${hypr_border:-"$(hyprctl -j getoption decoration:rounding | jq '.int')"}
    local wind_border=$((hypr_border * 3 / 2))
    local elem_border=$((hypr_border == 0 ? 5 : hypr_border))

    rofi_position=$(get_rofi_pos)

    local hypr_width=${hypr_width:-"$(hyprctl -j getoption general:border_size | jq '.int')"}
    r_override="window{border:${hypr_width}px;border-radius:${wind_border}px;}listview{border-radius:${elem_border}px;} element{border-radius:${elem_border}px;}"
}

# Rofi交互选择
rofi_select_layout() {
    setup_rofi_config
    
    selected=$(printf "%s\n" "${!LAYOUT_CONFIGS[@]}" | sort | \
        rofi -dmenu -i \
            -p "🎛️  Select Layout" \
            -theme-str "entry { placeholder: \" 🎛️  Switch layout...\";}" \
            -theme-str "${r_override}" \
            -theme-str "${font_override}" \
            -config "${ROFI_BOOKMARK_STYLE:-clipboard}" \
            -theme-str "window {width: 40%;}") 
    
    [[ -n "$selected" ]] && switch_layout "$selected"
}

# 显示当前布局
show_current_layout() {
    if command -v hyprctl >/dev/null && command -v jq >/dev/null; then
        current_layout=$(hyprctl -j getoption general:layout | jq -r '.str')
        echo "当前布局: $current_layout"
    else
        echo "无法获取当前布局"
    fi
}

# 显示用法
usage() {
    cat << EOF
用法: $0 [布局名称] 或 $0 [选项]

可用布局:
    master              - Master 布局
    master-top          - Master 顶部方向
    master-bottom       - Master 底部方向  
    master-left         - Master 左侧方向
    master-right        - Master 右侧方向
    master-center       - Master 居中方向
    master-next         - Master 下一个方向
    master-prev         - Master 上一个方向
    master-add-master   - Master 添加主区域
    master-remove-master- Master 移除主区域
    dwindle             - Dwindle 布局
    hy3                 - Hy3 布局
    nstack              - Nstack 布局
    scrolling           - Scrolling 布局
    river               - River 布局

选项:
    --interactive, -i  使用 rofi 交互选择
    --current, -c      显示当前布局
    --help, -h         显示此帮助信息
    --list, -l         列出所有可用布局

示例:
    $0 master          切换到 master 布局
    $0 master-top      切换到 master 顶部方向
    $0 -i              通过 rofi 选择布局
    $0 -c              显示当前布局
EOF
}

# 主函数
main() {
    case "$1" in
        "--interactive"|"-i")
            rofi_select_layout
            ;;
        "--current"|"-c")
            show_current_layout
            ;;
        "--list"|"-l")
            echo "可用布局:"
            printf "  %s\n" "${!LAYOUT_CONFIGS[@]}" | sort
            ;;
        "--help"|"-h")
            usage
            ;;
        "")
            echo "错误: 需要指定布局或使用交互模式"
            usage
            exit 1
            ;;
        *)
            switch_layout "$1"
            ;;
    esac
}

# 脚本入口
main "$@"