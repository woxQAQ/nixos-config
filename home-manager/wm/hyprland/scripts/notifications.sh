#!/usr/bin/env sh
## launch mako with alt config

CONFIG="$HOME/.config/hypr/mako/config"

if [[ ! $(pidof mako) ]]; then
	mako --config ${CONFIG}
fi