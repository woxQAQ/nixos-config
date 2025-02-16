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
    ./neovim
    ./terminal
    ./waypaper.nix
    ./fcitx
  ];
  # home = {
  #   inherit username;
  #   homeDirectory = "/home/${username}";
  #   stateVersion = "24.11";
  # };
  # programs.home-manager.enable = true;
}
