{
  username,
  stateVersion,
  ...
}:
{
  imports = [
    ./cli/mpv.nix
    ./pkgs.nix
    ./dev
  ];
  home = {
    homeDirectory = "/home/${username}";
    inherit stateVersion;
  };

  programs.home-manager.enable = true;
}
