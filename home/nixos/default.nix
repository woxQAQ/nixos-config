{
  nixvim,
  username,
  stateVersion,
  ...
}: {
  imports = [
    nixvim.homeManagerModules.nixvim
  ];
  home = {
    homeDirectory = "/home/${username}";
  };

  programs.home-manager.enable = true;
}
