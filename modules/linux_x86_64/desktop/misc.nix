{
  pkgs,
  pkgs-unstable,
  ...
}:
{
  environment.shells = with pkgs; [
    bashInteractive
    pkgs-unstable.nushell
  ];
  environment.systemPackages = with pkgs; [
    gnumake
  ];
  users.defaultUserShell = pkgs.bashInteractive;
  programs = {
    dconf.enable = true;
    thunar = {
      enable = true;
      plugins = with pkgs.xfce; [
        thunar-archive-plugin
        thunar-volman
      ];
    };
  };
}
