{
  username,
  # inputs,
  nixvim,
  mylib,
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
    nixvim.homeManagerModules.nixvim
    ./aerospace
    (lib.optionalString (builtins.any (x: x.name == "squirrel-app") osConfig.homebrew.casks) ./rime)
  ];
  home = {
    homeDirectory = "/Users/${username}";
    stateVersion = "25.05";
    packages = with pkgs; [
      # aerospace
      xterminal
      zotero
      # geminicli
      hidden-bar
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
