{
  username,
  # inputs,
  nixvim,
  mylib,
  pkgs,
  ...
}: let
  xterminal = pkgs.callPackage ../../pkg/xterminal {};
in {
  imports = [
    nixvim.homeManagerModules.nixvim
    ./aerospace
  ];
  home = {
    homeDirectory = "/Users/${username}";
    stateVersion = "25.05";
    packages = with pkgs; [
      aerospace
      xterminal
      hidden-bar
      antlr4_12
    ];
  };

  xdg.enable = true;
}
