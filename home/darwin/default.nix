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
  ++ lib.optional osConfig.modules.darwin.rime.enable ./rime;

  home = {
    homeDirectory = "/Users/${username}";
    stateVersion = "26.05";
    packages = with pkgs; [
      # keep-sorted start
      fastest-pkg.openlogi
      # nixpkgs-unstable's zotero 10.0.4 is pinned to Firefox ESR 153, which Zotero
      # cannot consume; nixpkgs-fast still ships 10.0.1 against Firefox ESR 140.
      fastest-pkg.zotero
      iina
      localsend
      maccy
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
