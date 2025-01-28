{
  pkgs,
  config,
  inputs,
  ...
}:
{
  home.packages = with pkgs; [
    # snex9x
    # sameboy
    gamescope
    hmcl
    winetricks
    prismlauncher
  ];
}