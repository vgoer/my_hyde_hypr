#!/usr/bin/env bash
# by -goer

# 初始化hyde环境（如果可用）
[[ "${HYDE_SHELL_INIT}" -ne 1 ]] && eval "$(hyde-shell init)" 2>/dev/null || true

# 浏览器配置
declare -A BROWSERS
BROWSERS=(
    ["google"]="google-chrome-stable"
    ["firefox"]="firefox"
    ["edge"]="microsoft-edge-stable"
    ["brave"]="brave"
    ["chromium"]="chromium"
)

# 默认浏览器
DEFAULT_BROWSER="google"
CURRENT_BROWSER="${BROWSERS[$DEFAULT_BROWSER]}"

# 搜索引擎配置
declare -A SEARCH_ENGINES
SEARCH_ENGINES=(
    ["google"]="https://www.google.com/search?q="
    ["bing"]="https://www.bing.com/search?q="
    ["duckduckgo"]="https://duckduckgo.com/?q="
    ["github"]="https://github.com/search?q="
    ["youtube"]="https://www.youtube.com/results?search_query="
    ["wikipedia"]="https://en.wikipedia.org/wiki/"
)

# 默认搜索引擎
DEFAULT_SEARCH_ENGINE="google"

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

# 切换浏览器
switch_browser() {
    local browser_key="$1"
    
    if [[ -z "${BROWSERS[$browser_key]}" ]]; then
        echo "错误: 不支持的浏览器 '$browser_key'"
        echo "可用浏览器: ${!BROWSERS[@]}"
        return 1
    fi
    
    CURRENT_BROWSER="${BROWSERS[$browser_key]}"
    echo "切换到浏览器: $browser_key ($CURRENT_BROWSER)"
}

# 切换搜索引擎
switch_search_engine() {
    local engine_key="$1"
    
    if [[ -z "${SEARCH_ENGINES[$engine_key]}" ]]; then
        echo "错误: 不支持的搜索引擎 '$engine_key'"
        echo "可用搜索引擎: ${!SEARCH_ENGINES[@]}"
        return 1
    fi
    
    DEFAULT_SEARCH_ENGINE="$engine_key"
    echo "切换到搜索引擎: $engine_key"
}

# 执行搜索
perform_search() {
    local query="$1"
    local engine="${2:-$DEFAULT_SEARCH_ENGINE}"
    local browser="${3:-$CURRENT_BROWSER}"
    
    if [[ -z "$query" ]]; then
        echo "错误: 搜索内容不能为空"
        return 1
    fi
    
    local search_url="${SEARCH_ENGINES[$engine]}${query}"
    
    echo "正在搜索: $query"
    echo "搜索引擎: $engine"
    echo "浏览器: $browser"
    echo "URL: $search_url"
    
    # 使用浏览器打开搜索链接
    if command -v "$browser" >/dev/null 2>&1; then
        nohup "$browser" "$search_url" >/dev/null 2>&1 &
        echo "已在 $browser 中打开搜索"
    else
        echo "错误: 浏览器 $browser 未安装，使用 xdg-open"
        nohup xdg-open "$search_url" >/dev/null 2>&1 &
    fi
}

# 浏览器选择菜单
select_browser() {
    setup_rofi_config
    
    selected=$(printf "%s\n" "${!BROWSERS[@]}" | sort | \
        rofi -dmenu -i \
            -p "🌐 选择浏览器" \
            -theme-str "entry { placeholder: \" 🌐 选择默认浏览器...\";}" \
            -theme-str "${r_override}" \
            -theme-str "${font_override}" \
            -config "${ROFI_BOOKMARK_STYLE:-clipboard}" \
            -theme-str "window {width: 30%;}")
    
    if [[ -n "$selected" ]]; then
        switch_browser "$selected"
        notify-send -u low "默认浏览器" "已切换到: $selected"
    fi
}

# 搜索引擎选择菜单
select_search_engine() {
    setup_rofi_config
    
    selected=$(printf "%s\n" "${!SEARCH_ENGINES[@]}" | sort | \
        rofi -dmenu -i \
            -p "🔍 选择搜索引擎" \
            -theme-str "entry { placeholder: \" 🔍 选择默认搜索引擎...\";}" \
            -theme-str "${r_override}" \
            -theme-str "${font_override}" \
            -config "${ROFI_BOOKMARK_STYLE:-clipboard}" \
            -theme-str "window {width: 30%;}")
    
    if [[ -n "$selected" ]]; then
        switch_search_engine "$selected"
        notify-send -u low "默认搜索引擎" "已切换到: $selected"
    fi
}

# 主搜索功能
rofi_search() {
    setup_rofi_config
    
    local query
    query=$(echo "" | rofi -dmenu -i \
        -p "🔍 搜索 ($DEFAULT_SEARCH_ENGINE)" \
        -theme-str "entry { placeholder: \" 🔍 在 $DEFAULT_SEARCH_ENGINE 中搜索...\";}" \
        -theme-str "${r_override}" \
        -theme-str "${font_override}" \
        -config "${ROFI_BOOKMARK_STYLE:-clipboard}" \
        -theme-str "window {width: 50%;}")
    
    if [[ -n "$query" ]]; then
        perform_search "$query"
    fi
}

# 高级搜索模式（选择搜索引擎）
rofi_advanced_search() {
    setup_rofi_config
    
    # 先选择搜索引擎
    local engine
    engine=$(printf "%s\n" "${!SEARCH_ENGINES[@]}" | sort | \
        rofi -dmenu -i \
            -p "🔍 选择搜索引擎" \
            -theme-str "entry { placeholder: \" 🔍 选择搜索引擎...\";}" \
            -theme-str "${r_override}" \
            -theme-str "${font_override}" \
            -config "${ROFI_BOOKMARK_STYLE:-clipboard}" \
            -theme-str "window {width: 40%;}")
    
    if [[ -z "$engine" ]]; then
        exit 0
    fi
    
    # 再输入搜索内容
    local query
    query=$(echo "" | rofi -dmenu -i \
        -p "🔍 搜索 ($engine)" \
        -theme-str "entry { placeholder: \" 🔍 在 $engine 中搜索...\";}" \
        -theme-str "${r_override}" \
        -theme-str "${font_override}" \
        -config "${ROFI_BOOKMARK_STYLE:-clipboard}" \
        -theme-str "window {width: 50%;}")
    
    if [[ -n "$query" ]]; then
        perform_search "$query" "$engine"
    fi
}

# 显示当前设置
show_current_settings() {
    echo "当前默认浏览器: $CURRENT_BROWSER"
    echo "当前默认搜索引擎: $DEFAULT_SEARCH_ENGINE"
    echo ""
    echo "可用浏览器:"
    for browser in "${!BROWSERS[@]}"; do
        echo "  - $browser: ${BROWSERS[$browser]}"
    done
    echo ""
    echo "可用搜索引擎:"
    for engine in "${!SEARCH_ENGINES[@]}"; do
        echo "  - $engine: ${SEARCH_ENGINES[$engine]}"
    done
}

# 显示用法
usage() {
    cat << EOF
用法: $0 [选项]

搜索工具 - 通过 Rofi 快速搜索

选项:
    --search, -s          直接搜索（使用默认设置）
    --advanced-search, -a 高级搜索（选择搜索引擎）
    --browser, -b         切换默认浏览器
    --engine, -e          切换默认搜索引擎
    --current, -c         显示当前设置
    --help, -h            显示此帮助信息

示例:
    $0 -s                 打开搜索框直接搜索
    $0 -a                 选择搜索引擎后搜索
    $0 -b                 切换默认浏览器
    $0 -e                 切换默认搜索引擎
    $0 --browser firefox  切换到 Firefox
    $0 --engine bing      切换到 Bing 搜索

快捷键建议（在 Hyprland 配置中添加）:
    bind = SUPER, G, exec, $0 -s
    bind = SUPER_SHIFT, G, exec, $0 -a
    bind = SUPER, B, exec, $0 -b
EOF
}

# 解析命令行参数
main() {
    case "$1" in
        "--search"|"-s")
            rofi_search
            ;;
        "--advanced-search"|"-a")
            rofi_advanced_search
            ;;
        "--browser"|"-b")
            if [[ -n "$2" ]]; then
                switch_browser "$2"
            else
                select_browser
            fi
            ;;
        "--engine"|"-e")
            if [[ -n "$2" ]]; then
                switch_search_engine "$2"
            else
                select_search_engine
            fi
            ;;
        "--current"|"-c")
            show_current_settings
            ;;
        "--help"|"-h")
            usage
            ;;
        "")
            # 默认行为：直接搜索
            rofi_search
            ;;
        *)
            echo "未知选项: $1"
            usage
            exit 1
            ;;
    esac
}

# 脚本入口
main "$@"