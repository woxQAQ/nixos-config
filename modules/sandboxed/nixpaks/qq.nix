{
  lib,
  qq,
  mkNixpak,
  buildEnv,
  makeDesktopItem,
  ...
}:
let
  appId = "com.qq.QQ";
  wrapped = mkNixpak {
    config =
      { sloth, ... }:
      {
        app = {
          package = qq;
          binPath = "bin/qq";
        };
        flatpak.appId = appId;

        imports = [
          ./modules/gui-base.nix
          ./modules/network.nix
          ./modules/common.nix
        ];
        bubblewrap = {
          bind.rw = with sloth; [
            xdgDocumentsDir
            xdgDownloadDir
            xdgMusicDir
            xdgVideosDir
            xdgPicturesDir
          ];
          sockets = {
            wayland = true;
            x11 = false;
            pipewire = true;
          };
        };
      };
  };
  exePath = lib.getExe wrapped.config.script;
in

buildEnv {
  inherit (wrapped.config.script) name meta passthru;
  paths = [
    wrapped.config.script
    (makeDesktopItem {
      name = appId;
      desktopName = "QQ";
      genericName = "QQ Boxed";
      comment = "Tencent QQ, also known as QQ, is an instant messaging software service and web portal developed by the Chinese technology company Tencent.";
      exec = "${exePath} %U";
      terminal = false;
      icon = "${qq}/share/icons/hicolor/512x512/apps/qq.png";
      startupNotify = true;
      startupWMClass = "QQ";
      type = "Application";
      categories = [
        "InstantMessaging"
        "Network"
      ];
      extraConfig = {
        X-Flatpak = appId;
      };
    })
  ];
}
