{
  pkgs,
  nur-ryan4yin,
  config,
  ...
}:
{
  imports = [
    ./waybar.nix
    ./anyrun.nix
    ./xdg.nix
    ./apps.nix
    ./pkgs.nix
  ];

  programs = {
    wlogout.enable = true;
  };

  catppuccin = {
    waybar.enable = false;
    wlogout.enable = false;
    mako.enable = false;
  };

  services = {
    mako.enable = true;
    hypridle.enable = true;
  };
  wayland.windowManager.hyprland = {
    enable = true;
    systemd = {
      enable = true;
      variables = [ "--all" ];
    };
    # package = hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
    package = pkgs.hyprland;
    settings = {
      source =
        let
          configPath = "${config.home.homeDirectory}/.config/hypr/configs";
        in
        [
          "${configPath}/exec.conf"
          "${configPath}/fcitx5.conf"
          "${configPath}/keybinds.conf"
          "${configPath}/settings.conf"
          "${configPath}/windowrules.conf"
        ];
      env = [
        # "HYPRCURSOR_THEME,Bibata-Modern-Ice"
        # "HYPRCURSOR_SIZE,16"
        "NIXOS_OZONE_WL,1" # for any ozone-based browser & electron apps to run on wayland
        "MOZ_ENABLE_WAYLAND,1" # for firefox to run on wayland
        "MOZ_WEBRENDER,1"
        # misc
        # "USE_WAYLAND_GRIM,1"
        "_JAVA_AWT_WM_NONREPARENTING,1"
        "QT_WAYLAND_DISABLE_WINDOWDECORATION,1"
        "QT_QPA_PLATFORM,wayland"
        "SDL_VIDEODRIVER,wayland"
        "GDK_BACKEND,wayland"
        "XDG_SESSION_TYPE,wayland"
        # "GDK_SCALE,1.25"
        "ELECTRON_OZONE_PLATFORM_HINT,auto"
        # "XCURSOR_SIZE,24"
        # "XDG_CURRENT_DESKTOP,Hyprland"
        # "XDG_SESSION_DESKTOP,Hyprland"
        # "GTK_IM_MODULE,fcitx"
        # "QT_IM_MODULE,fcitx"
        # "XMODIFIERS,@im=fcitx"
        # "SDL_IM_MODULE,fcitx"
        # "GLFW_IM_MODULE,ibus"
      ];
    };
  };
  home.file.".wayland-session" = {
    source = "${pkgs.hyprland}/bin/Hyprland";
    executable = true;
  };
  xdg.configFile =
    let
      mkSymlink = config.lib.file.mkOutOfStoreSymlink;
    in
    {
      "waybar".source = mkSymlink ./conf/waybar;
      "wlogout".source = mkSymlink ./conf/wlogout;
      "mako".source = mkSymlink ./conf/mako;
      "hypr/configs".source = mkSymlink ./conf/hypr;
    };
}
