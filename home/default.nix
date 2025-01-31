{
  config,
  pkgs,
  username,
  host,
  inputs,
  nur-ryan4yin,
  ...
}:
{
  imports = [
    ./program
    ./wm
    ./terminal
    ./waypaper.nix
    ./neovim
    ./fcitx
  ];
  # home = {
  #   inherit username;
  #   homeDirectory = "/home/${username}";
  #   stateVersion = "24.11";
  # };
  # programs.home-manager.enable = true;
}
