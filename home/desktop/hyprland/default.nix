{
  pkgs,
  config,
  lib,
  username,
  ...
}:
let
  enabled = config.modules.desktop.environment == "hyprland";
in
{
  imports =
    [ ]
    ++ lib.optionals enabled [
      ./waybar.nix
      ./anyrun.nix
      ./xdg.nix
      ./apps.nix
      ./pkgs.nix
      ./conf
    ];
  wayland.windowManager.hyprland = lib.mkIf enabled {
    enable = true;
    systemd = {
      enable = true;
      variables = [ "--all" ];
    };
    # package = hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
    package = pkgs.hyprland;
    settings = {
      exec-once =
        let
          wallpaper = pkgs.callPackage ./scripts/wallpaper.nix {
            inherit (import ../../../hosts/${username}/values.nix) defaultWallpaper;
          };
        in
        [
          "${lib.getExe wallpaper}"
          "${lib.getExe' pkgs.clash-nyanpasu "clash-nyanpasu"}"
        ];
      source =
        let
          configPath = "${config.home.homeDirectory}/.config/hypr/configs";
        in
        [
          "${configPath}/fcitx5.conf"
          "${configPath}/exec.conf"
          "${configPath}/keybinds.conf"
          "${configPath}/settings.conf"
          "${configPath}/windowrules.conf"
        ];
      env = [
        # keep-sorted start
        "ELECTRON_OZONE_PLATFORM_HINT,auto"
        "GDK_BACKEND,wayland,x11,*"
        "MOZ_ENABLE_WAYLAND,1" # for firefox to run on wayland
        "MOZ_WEBRENDER,1"
        "NIXOS_OZONE_WL,1" # for any ozone-based browser & electron apps to run on wayland
        "QT_AUTO_SCREEN_SCALE_FACTOR,1"
        "QT_QPA_PLATFORM,wayland;xcb"
        "QT_QPA_PLATFORMTHEME,qt6ct"
        "QT_WAYLAND_DISABLE_WINDOWDECORATION,1"
        "SDL_VIDEODRIVER,wayland"
        "XCURSOR,Catppuccin-Mocha-Dark-Cursors"
        "XCURSOR_SIZE,24"
        "XDG_CURRENT_DESKTOP,Hyprland"
        "XDG_SESSION_TYPE,wayland"
        "_JAVA_AWT_WM_NONREPARENTING,1"
        # keep-sorted end
      ];
    };
  };
  home.file.".wayland-session" = lib.mkIf enabled {
    source = "${pkgs.hyprland}/bin/Hyprland";
    executable = true;
  };

}
