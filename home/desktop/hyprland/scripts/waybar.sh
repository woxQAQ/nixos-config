#!/usr/bin/env sh

STYLE="$HOME/.config/hypr/waybar/style.less"
CONFIG="$HOME/.config/hypr/waybar/config.jsonc"

if [[ ! $(pidof waybar) ]]; then
    waybar --log-level error --style ${STYLE} --config ${CONFIG}
fi
