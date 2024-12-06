{
  config,
  pkgs,
  username,
  host,
  inputs,
  ...
}:
{
  imports = [
    ./program
    ./wm
  ];
  home = {
    inherit username;
    homeDirectory = "/home/${username}";
    stateVersion = "24.11";
  };
  programs.home-manager.enable = true;
}
