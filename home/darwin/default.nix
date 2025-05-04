{
  username,
  # inputs,
  nixvim,
  ...
}: {
  imports = [
    nixvim.homeManagerModules.nixvim
    ./aerospace
  ];
  home = {
    homeDirectory = "/Users/${username}";
    stateVersion = "25.05";
  };

  xdg.enable = true;
}
