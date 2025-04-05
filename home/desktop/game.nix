{pkgs, ...}: {
  home.packages = with pkgs; [
    # snex9x
    # sameboy
    gamescope
    hmcl
    winetricks
    prismlauncher
  ];
}
