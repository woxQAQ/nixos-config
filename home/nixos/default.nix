{
  nixvim,
  username,
  stateVersion,
  ...
}:
{
  imports = [
    nixvim.homeManagerModules.nixvim
  ];
  home = {
    homeDirectory = "/home/${username}";
    inherit stateVersion;
  };

  programs.home-manager.enable = true;
}
