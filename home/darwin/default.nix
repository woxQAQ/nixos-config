{
  username,
  pkgs,
  lib,
  config,
  osConfig,
  fastest-pkg,
  ...
}:
{
  imports = [
    ./aerospace
  ]
  ++ lib.optional (builtins.any (x: x.name == "squirrel-app") osConfig.homebrew.casks) ./rime;

  home = {
    homeDirectory = "/Users/${username}";
    stateVersion = "26.05";
    packages = with pkgs; [
      # keep-sorted start
      fastest-pkg.openlogi
      iina
      localsend
      maccy
      podman
      podman-compose
      podman-tui
      zotero
      # keep-sorted end
    ];
  };
  programs.mpv = {
    enable = true;
    config = {
      screenshot-format = "webp";
      screenshot-webp-lossless = true;
      screenshot-directory = "${config.home.homeDirectory}/Pictures/Screenshots/mpv";
      screenshot-sw = true;
    };
    scripts = with pkgs.mpvScripts; [
      thumbnail
    ];
  };

  services.macos-remap-keys = {
    enable = pkgs.stdenv.hostPlatform.isDarwin;
    keyboard = {
      Capslock = "Escape";
      Escape = "Capslock";
    };
  };

  xdg.configFile."mole/whitelist".text = ''
    ${config.home.homeDirectory}/Library/Caches/Dia
    ${config.home.homeDirectory}/Library/Application Support/Dia
  '';
  xdg.enable = true;
}
