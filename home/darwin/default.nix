{
  inputs,
  username,
  ...
}: {
  imports = [
    inputs.nixvim.homeManagerModules.nixvim
  ];
  home = {
    homeDirectory = "/Users/${username}";
    stateVersion = "25.05";
  };

  xdg.enable = true;
}
