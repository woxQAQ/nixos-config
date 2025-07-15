{ ... }:
{
  wayland.windowManager.hyprland = {
    settings = {
      exec-once = [
        "hash dbus-update-activation-environment 2>/dev/null &"
        "dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP &"
        # "wl-clip-persist --clipboard both &"
        "wl-paste --watch cliphist store &"
        # "waybar --bar main-bar --log-level error --style ~/.config/waybar/style.css &"
        "sh ~/.config/hypr/scripts/startup.sh"
        "nm-applet &"
        "swww-daemon &"
        "fcitx5 -d"
        # "hyprctl setcursor Bibata-Modern-Classic 24"
      ];
      input = {
        kb_layout = "us";
        # kb_options = "caps:capslock";
        numlock_by_default = true;
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
        gaps_out = 10;
        border_size = 4;
        "col.active_border" = "0xFFB4A1DB";
        "col.inactive_border" = "0xFF343A40";
        # border_part_of_window = false;
        # no_border_on_floating = false;
      };
      # misc = {
      #   disable_autoreload = true;
      #   disable_hyprland_logo = true;
      #   always_follow_on_dnd = true;
      #   layers_hog_keyboard_focus = true;
      #   animate_manual_resizes = false;
      #   enable_swallow = true;
      #   focus_on_activate = true;
      #   new_window_takes_over_fullscreen = 2;
      #   middle_click_paste = false;
      # };

      dwindle = {
        # no_gaps_when_only = false;
        pseudotile = 0;
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
          size = 3;
          passes = 1;
          brightness = 1;
          contrast = 1.4;
          ignore_opacity = false;
          noise = 0;
          new_optimizations = true;
          xray = true;
        };

        shadow = {
          enabled = true;

          ignore_window = true;
          offset = "0 2";
          range = 20;
          render_power = 3;
          color = "rgba(00000055)";
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
  };
}
