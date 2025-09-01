{
  username,
  # inputs,
  nixvim,
  pkgs,
  lib,
  osConfig,
  ...
}:
let
  xterminal = pkgs.callPackage ../../pkg/xterminal { };
in
{
  imports = [
    nixvim.homeModules.nixvim
    ./aerospace
    (lib.optionalString (builtins.any (x: x.name == "squirrel-app") osConfig.homebrew.casks) ./rime)
  ];
  home = {
    homeDirectory = "/Users/${username}";
    stateVersion = "25.05";
    packages = with pkgs; [
      xterminal
      zotero
      hidden-bar
      ups
      iina
      stats
      maccy
      podman
      podman-compose
      podman-tui
    ];
  };

  xdg.enable = true;
}
