{
  username,
  stateVersion,
  ...
}:
{
  imports = [
    ./cli/mpv.nix
  ];
  home = {
    homeDirectory = "/home/${username}";
    inherit stateVersion;
  };

  programs.home-manager.enable = true;
}
