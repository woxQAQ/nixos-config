#!/usr/bin/env sh

if [[ ! $(pidof anyrun) ]]; then
  anyrun
else
  pkill anyrun
fi
