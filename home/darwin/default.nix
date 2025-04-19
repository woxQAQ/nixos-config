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

  nixpkgs = {
    config = {
      allowUnfree = true;
    };
  };

  xdg.enable = true;
}
