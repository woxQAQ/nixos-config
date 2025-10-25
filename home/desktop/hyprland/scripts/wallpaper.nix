{ pkgs, defaultWallpaper, ... }:
pkgs.writeShellScriptBin "wallpaper" ''
  swww restore &> /dev/null
  if ! swww query | grep -q "image:" &> /dev/null; then
    swww img "${../../../../assets/${defaultWallpaper}}"
  fi
''
