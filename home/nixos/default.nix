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
    inherit stateVersion;
  };

  programs.home-manager.enable = true;
}
