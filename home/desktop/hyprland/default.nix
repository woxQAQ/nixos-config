{
  pkgs,
  inputs,
  nur-ryan4yin,
  anyrun,
  ...
}: {
  imports = [
    # anyrun.homeManagerModules.default
    ./config.nix
    ./waybar.nix
    ./windowrule.nix
    ./keybinds.nix
    ./anyrun.nix
  ];

  home.packages = with pkgs; [
    eww
    swww
    slurp
    hyprcursor
    wl-clip-persist
    cliphist
    wf-recorder
    glib
    weston
    wayland
    imv
    pamixer
    hyprshot
    mako
    wlogout
    swaylock
    swaybg
    wlr-randr
    alsa-utils
    networkmanagerapplet
  ];
  systemd.user.targets.hyprland-session.Unit.Wants = [
    "xdg-desktop-autostart.target"
  ];
  wayland.windowManager.hyprland = {
    enable = true;
    systemd.enable = true;
    package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
    settings = {
      source = "${nur-ryan4yin.packages.${pkgs.system}.catppuccin-hyprland}/themes/mocha.conf";
      env = [
        "HYPRCURSOR_THEME,Bibata-Modern-Ice"
        "HYPRCURSOR_SIZE,24"
        "NIXOS_OZONE_WL,1" # for any ozone-based browser & electron apps to run on wayland
        "MOZ_ENABLE_WAYLAND,1" # for firefox to run on wayland
        "MOZ_WEBRENDER,1"
        # misc
        "USE_WAYLAND_GRIM,1"
        "_JAVA_AWT_WM_NONREPARENTING,1"
        "QT_WAYLAND_DISABLE_WINDOWDECORATION,1"
        "QT_QPA_PLATFORM,wayland"
        "SDL_VIDEODRIVER,wayland"
        "GDK_BACKEND,wayland"
        "GDK_SCALE,1.25"
        "XCURSOR_SIZE,24"
        "XDG_SESSION_TYPE,wayland"
        "XDG_CURRENT_DESKTOP,Hyprland"
        "XDG_SESSION_DESKTOP,Hyprland"
        "GTK_IM_MODULE,fcitx"
        "QT_IM_MODULE,fcitx"
        "XMODIFIERS,@im=fcitx"
        "SDL_IM_MODULE,fcitx"
        "GLFW_IM_MODULE,ibus"
      ];
    };
  };
  home.file.".wayland-session" = {
    source = "${pkgs.hyprland}/bin/Hyprland";
    executable = true;
  };
  xdg.configFile = {
    "hypr/waybar" = {
      source = ./conf/waybar;
      recursive = true;
    };
    "hypr/wlogout" = {
      source = ./conf/wlogout;
      recursive = true;
    };
    "hypr/mako" = {
      source = ./conf/mako;
      recursive = true;
    };
    "hypr/scripts" = {
      source = ./scripts;
      recursive = true;
    };
  };
}
