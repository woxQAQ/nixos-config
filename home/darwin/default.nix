{
  username,
  pkgs,
  lib,
  config,
  osConfig,
  ...
}:
{
  imports = [
    ./aerospace
  ]
  ++ lib.optional (builtins.any (x: x.name == "squirrel-app") osConfig.homebrew.casks) ./rime;

  home = {
    homeDirectory = "/Users/${username}";
    stateVersion = "25.05";
    packages = with pkgs; [
      # keep-sorted start
      buf
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

  xdg.enable = true;
}
