{
  inputs,
  username,
  stateVersion,
  ...
}: {
  imports = [
    inputs.nixvim.homeManagerModules.nixvim
  ];
  home = {
    homeDirectory = "/home/${username}";
  };

  programs.home-manager.enable = true;
}
