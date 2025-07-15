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
  geminicli = pkgs.callPackage ../../pkg/gemini-cli { };
  claude-code-wrapper = pkgs.callPackage ../../pkg/claude-code-wrapper { };
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
      wireshark
      xterminal
      # geminicli
      claude-code-wrapper
      hidden-bar
      iina
      code-cursor
      stats
      maccy
    ];
  };

  xdg.enable = true;
}
