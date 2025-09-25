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
    # use rime-ice as rime theme and dict
    (lib.optionalString (builtins.any (x: x.name == "squirrel-app") osConfig.homebrew.casks) ./rime)
  ];
  home = {
    homeDirectory = "/Users/${username}";
    stateVersion = "25.05";
    packages = with pkgs; [
      # keep-sorted start

      # a Schema-driven protobuf framework
      buf
      # a MacOS video player
      iina
      # local area network file Transfer util
      localsend
      # a MacOS clipboard manager
      maccy
      # podman
      podman
      podman-compose
      podman-tui
      # a menu bar util to show computer stats
      stats
      # a utils for apply & edit UPS patcher
      ups
      xterminal
      # paper collect & manager
      zotero
      #keep-sorted end
    ];
  };

  xdg.enable = true;
}
