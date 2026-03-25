{
  username,
  pkgs,
  lib,
  config,
  osConfig,
  ...
}:
# let
#   xterminal = pkgs.callPackage ../../pkg/xterminal { };
# in
{
  imports = [
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
      # an util for apply & edit UPS patcher
      # ups
      # xterminal
      # paper collect & manager
      zotero
      #keep-sorted end
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

  # macOS 26 登录后不会继承 boot 阶段的 hidutil 映射，
  # 用用户级 LaunchAgent 在图形会话启动时重新应用一次。
  services.macos-remap-keys = {
    enable = pkgs.stdenv.hostPlatform.isDarwin;
    keyboard = {
      Capslock = "Escape";
      Escape = "Capslock";
    };
  };

  xdg.enable = true;
}
