{
  config,
  pkgs,
  inputs,
  host,
  ...
}:
{
  imports = [
    ./hyprland
    ./waybar
  ];
}
