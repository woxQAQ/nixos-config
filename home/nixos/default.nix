{
  username,
  stateVersion,
  ...
}:
{
  imports = [
    ./cli/mpv.nix
    ./dev
  ];
  home = {
    homeDirectory = "/home/${username}";
    inherit stateVersion;
  };

  programs.home-manager.enable = true;
}
