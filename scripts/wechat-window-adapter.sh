#!/bin/sh
set -eu

if [ "${WECHAT_MOBILE_ADAPT:-0}" != "1" ]; then
    exit 0
fi

timeout="${WECHAT_WINDOW_WAIT_TIMEOUT:-30}"
margin="${WECHAT_WINDOW_MARGIN:-0}"
mode="${WECHAT_WINDOW_MODE:-fit}"

display_width="${DISPLAY_WIDTH:-1920}"
display_height="${DISPLAY_HEIGHT:-1080}"
target_width="${WECHAT_WINDOW_WIDTH:-$((display_width - margin * 2))}"
target_height="${WECHAT_WINDOW_HEIGHT:-$((display_height - margin * 2))}"
target_x="${WECHAT_WINDOW_X:-$margin}"
target_y="${WECHAT_WINDOW_Y:-$margin}"

find_window() {
    xdotool search --onlyvisible --class wechat 2>/dev/null | head -n 1 || true
}

elapsed=0
window_id=""
while [ "$elapsed" -lt "$timeout" ]; do
    window_id="$(find_window)"
    if [ -n "$window_id" ]; then
        break
    fi
    sleep 1
    elapsed=$((elapsed + 1))
done

if [ -z "$window_id" ]; then
    echo "wechat-window-adapter: could not find WeChat window within ${timeout}s" >&2
    exit 0
fi

wmctrl -ir "$window_id" -b remove,maximized_vert,maximized_horz,fullscreen 2>/dev/null || true

case "$mode" in
    maximize)
        xdotool windowmove "$window_id" "$target_x" "$target_y" 2>/dev/null || true
        xdotool windowsize "$window_id" "$target_width" "$target_height" 2>/dev/null || true
        wmctrl -ir "$window_id" -b add,maximized_vert,maximized_horz 2>/dev/null || true
        ;;
    fit|*)
        xdotool windowmove "$window_id" "$target_x" "$target_y" 2>/dev/null || true
        xdotool windowsize "$window_id" "$target_width" "$target_height" 2>/dev/null || true
        ;;
esac

exit 0
