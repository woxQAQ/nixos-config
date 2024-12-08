#!/usr/bin/env sh
# Kill already running process
_ps=(waybar mako)
for _prs in "${_ps[@]}"; do
	echo ${_prs}
	if [[ $(pidof ${_prs}) ]]; then
		kill $(pidof ${_prs})
	fi
done

~/.config/hypr/scripts/waybar.sh &