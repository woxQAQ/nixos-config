{ ... }:
{
  wayland.windowManager.hyprland.settings = {
    exec-once = [
      "ln -s $XDG_RUNTIME_DIR/hypr /tmp/hypr"
      "hash dbus-update-activation-environment 2>/dev/null &"
      "dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP &"
      # "wl-clip-persist --clipboard both &"
      "wl-paste --watch cliphist store &"
      # "waybar --bar main-bar --log-level error --style ~/.config/waybar/style.css &"
      # "sh ~/.config/hypr/scripts/startup.sh"
      "nm-applet &"
      "swww-daemon &"
      "fcitx5 -d -r"
      "fcitx5-remote -r"
      "mihomo-party"
      # "hyprctl setcursor Bibata-Modern-Classic 24"
    ];
    input = {
      kb_layout = "us";
      # kb_options = "caps:capslock";
      numlock_by_default = true;
      force_no_accel = 0;
      follow_mouse = 1;
      float_switch_override_focus = 0;
      mouse_refocus = false;
      sensitivity = 0;
      touchpad = {
        natural_scroll = true;
      };
    };
    general = {
      "$mainMod" = "SUPER";
      gaps_in = 5;
      gaps_out = 5;
      border_size = 2;
      "col.active_border" = "0xff4477ff";
      "col.inactive_border" = "0xFF2f343F";
      resize_on_border = false;
      hover_icon_on_border = false;
      layout = "dwindle";
      no_focus_fallback = true;
    };
    # cusror = {
    #   inactive_timeout = 900;
    #   no_wraps = false;
    # };
    ecosystem = {
      no_donation_nag = true;
      no_update_news = true;
    };

    dwindle = {
      # no_gaps_when_only = false;
      pseudotile = "yes";
      preserve_split = "yes";
    };

    master = {
      new_status = "master";
      special_scale_factor = 1;
      # no_gaps_when_only = false;
    };

    decoration = {
      rounding = 8;
      active_opacity = 1.0;
      inactive_opacity = 0.9;
      fullscreen_opacity = 1.0;

      blur = {
        enabled = true;
        new_optimizations = true;
        size = 3;
        passes = 1;
        brightness = 1;
        contrast = 1.4;
        ignore_opacity = false;
        noise = 0;
        xray = true;
      };

      shadow = {
        enabled = true;
        # ignore_window = true;
        # offset = "0 2";
        range = 4;
        render_power = 3;
        color = "rgba(1a1a1aee)";
      };
    };

    animations = {
      enabled = true;

      bezier = [
        "fluent_decel, 0, 0.2, 0.4, 1"
        "easeOutCirc, 0, 0.55, 0.45, 1"
        "easeOutCubic, 0.33, 1, 0.68, 1"
        "fade_curve, 0, 0.55, 0.45, 1"
      ];

      animation = [
        # name, enable, speed, curve, style

        # Windows
        "windowsIn,   0, 4, easeOutCubic,  popin 20%" # window open
        "windowsOut,  0, 4, fluent_decel,  popin 80%" # window close.
        "windowsMove, 1, 2, fluent_decel, slide" # everything in between, moving, dragging, resizing.

        # Fade
        "fadeIn,      1, 3,   fade_curve" # fade in (open) -> layers and windows
        "fadeOut,     1, 3,   fade_curve" # fade out (close) -> layers and windows
        "fadeSwitch,  0, 1,   easeOutCirc" # fade on changing activewindow and its opacity
        "fadeShadow,  1, 10,  easeOutCirc" # fade on changing activewindow for shadows
        "fadeDim,     1, 4,   fluent_decel" # the easing of the dimming of inactive windows
        # "border,      1, 2.7, easeOutCirc"  # for animating the border's color switch speed
        # "borderangle, 1, 30,  fluent_decel, once" # for animating the border's gradient angle - styles: once (default), loop
        "workspaces,  1, 4,   easeOutCubic, fade" # styles: slide, slidevert, fade, slidefade, slidefadevert
      ];
    };
    # mouse binding
    bindm = [
      "$mainMod, mouse:272, movewindow"
      "$mainMod, mouse:273, resizewindow"
    ];
    monitor = [
      "DP-3,2560x1440@180,2048x0,1.25"
      "HDMI-A-2,2560x1440@144,0x0,1.25"
    ];
    xwayland = {
      force_zero_scaling = true;
    };
  };
}
