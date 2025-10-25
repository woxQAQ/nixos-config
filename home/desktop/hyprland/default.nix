{
  pkgs,
  config,
  lib,
  username,
  ...
}:
{
  imports = [
    ./waybar.nix
    ./anyrun.nix
    ./xdg.nix
    ./apps.nix
    ./pkgs.nix
    ./conf
  ];
  wayland.windowManager.hyprland = {
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
        # "HYPRCURSOR_THEME,Bibata-Modern-Ice"
        # "HYPRCURSOR_SIZE,16"
        "NIXOS_OZONE_WL,1" # for any ozone-based browser & electron apps to run on wayland
        "QT_QPA_PLATFORM,wayland"
        "QT_WAYLAND_DISABLE_WINDOWDECORATION,1"
        "SDL_VIDEODRIVER,wayland"
        "XDG_SESSION_TYPE,wayland"
        # misc
        # "USE_WAYLAND_GRIM,1"
        "_JAVA_AWT_WM_NONREPARENTING,1"
        # keep-sorted end
      ];
    };
  };
  home.file.".wayland-session" = {
    source = "${pkgs.hyprland}/bin/Hyprland";
    executable = true;
  };

}
