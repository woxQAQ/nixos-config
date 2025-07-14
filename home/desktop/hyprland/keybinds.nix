{
  wayland.windowManager.hyprland = {
    settings = {
      bind =
        let
          applauncher = "~/.config/hypr/scripts/menu.sh";
        in
        [
          # show keybinds list
          # "$mainMod, F1, exec, show-keybinds"

          # keybindings
          "$mainMod, Return, exec, alacritty"
          "ALT, Return, exec, [float; center; size 950 650] alacritty"
          "$mainMod SHIFT, Return, exec, [fullscreen] alacritty"
          # "$mainMod, B, exec, hyprctl dispatch exec '[workspace 1 silent] zen'"
          "$mainMod, Q, killactive,"
          "$mainMod, F, fullscreen, 0"
          "$mainMod SHIFT, F, fullscreen, 1"
          "$mainMod, T, togglefloating"
          "$mainMod, C, exec, cursor"
          # "$mainMod, Space, exec, ${applauncher}"
          "$mainMod, Space, exec, anyrun"
          # "$mainMod SHIFT, D, exec, webcord --enable-features=UseOzonePlatform --ozone-platform=wayland"
          "$mainMod SHIFT, S, exec, hyprctl dispatch exec '[workspace 5 silent] SoundWireServer'"
          # "$mainMod, Escape, exec, swaylock"
          # "ALT, Escape, exec, hyprlock"
          # "$mainMod SHIFT, Escape, exec, power-menu"
          "$mainMod, P, pseudo,"
          "$mainMod, X, togglesplit,"
          # "CTRL SHIFT, A, exec, XDG_CURRENT_DESKTOP=sway flameshot gui -p ~/Pictures/Screenshots | wl-copy"
          # "$mainMod, T, exec, toggle_oppacity"
          # "$mainMod CTRL, E, exec, nemo"
          # "$mainMod, E, exec, hyprctl dispatch exec '[float; center; size 1111 700] nemo'"
          # "$mainMod SHIFT, E, exec, hyprctl dispatch exec '[float; center; size 1111 700] kitty yazi'"
          # "$mainMod SHIFT, B, exec, toggle_waybar"
          "$mainMod, C ,exec, hyprpicker -a"
          # "$mainMod, W,exec, wallpaper-picker"
          "$mainMod SHIFT, W,exec, hyprctl dispatch exec '[float; center; size 925 615] waypaper'"
          "$mainMod, N, exec, swaync-client -t -sw"
          # "$mainMod SHIFT, W, exec, vm-start"

          # screenshot
          "CTRL ALT, A, exec, hyprshot -m region -o ~/Pictures/Screenshots -- imv"
          "CTRL SHIFT,A, exec, hyprshot -m output -o ~/Pictures/Screenshots -- imv"
          "$mainMod, Escape, exec, hyprshot -m window -o ~/Pictures/Screenshots -- imv"

          # switch focus
          "$mainMod, left, movefocus, l"
          "$mainMod, right, movefocus, r"
          "$mainMod, up, movefocus, u"
          "$mainMod, down, movefocus, d"
          "$mainMod, h, movefocus, l"
          "$mainMod, j, movefocus, d"
          "$mainMod, k, movefocus, u"
          "$mainMod, l, movefocus, r"

          # switch workspace
          "$mainMod, 1, workspace, 1"
          "$mainMod, 2, workspace, 2"
          "$mainMod, 3, workspace, 3"
          "$mainMod, 4, workspace, 4"
          "$mainMod, 5, workspace, 5"
          "$mainMod, 6, workspace, 6"
          "$mainMod, 7, workspace, 7"
          "$mainMod, 8, workspace, 8"
          "$mainMod, 9, workspace, 9"
          "$mainMod, 0, workspace, 10"

          # same as above, but switch to the workspace
          "$mainMod SHIFT, 1, movetoworkspacesilent, 1" # movetoworkspacesilent
          "$mainMod SHIFT, 2, movetoworkspacesilent, 2"
          "$mainMod SHIFT, 3, movetoworkspacesilent, 3"
          "$mainMod SHIFT, 4, movetoworkspacesilent, 4"
          "$mainMod SHIFT, 5, movetoworkspacesilent, 5"
          "$mainMod SHIFT, 6, movetoworkspacesilent, 6"
          "$mainMod SHIFT, 7, movetoworkspacesilent, 7"
          "$mainMod SHIFT, 8, movetoworkspacesilent, 8"
          "$mainMod SHIFT, 9, movetoworkspacesilent, 9"
          "$mainMod SHIFT, 0, movetoworkspacesilent, 10"
          "$mainMod CTRL, c, movetoworkspace, empty"

          # window control
          "$mainMod SHIFT, left, movewindow, l"
          "$mainMod SHIFT, right, movewindow, r"
          "$mainMod SHIFT, up, movewindow, u"
          "$mainMod SHIFT, down, movewindow, d"
          "$mainMod SHIFT, h, movewindow, l"
          "$mainMod SHIFT, j, movewindow, d"
          "$mainMod SHIFT, k, movewindow, u"
          "$mainMod SHIFT, l, movewindow, r"

          "$mainMod CTRL, left, resizeactive, -80 0"
          "$mainMod CTRL, right, resizeactive, 80 0"
          "$mainMod CTRL, up, resizeactive, 0 -80"
          "$mainMod CTRL, down, resizeactive, 0 80"
          "$mainMod CTRL, h, resizeactive, -80 0"
          "$mainMod CTRL, j, resizeactive, 0 80"
          "$mainMod CTRL, k, resizeactive, 0 -80"
          "$mainMod CTRL, l, resizeactive, 80 0"

          "$mainMod ALT, left, moveactive,  -80 0"
          "$mainMod ALT, right, moveactive, 80 0"
          "$mainMod ALT, up, moveactive, 0 -80"
          "$mainMod ALT, down, moveactive, 0 80"
          "$mainMod ALT, h, moveactive,  -80 0"
          "$mainMod ALT, j, moveactive, 0 80"
          "$mainMod ALT, k, moveactive, 0 -80"
          "$mainMod ALT, l, moveactive, 80 0"

          # media and volume controls
          # ",XF86AudioMute,exec, pamixer -t"
          ",XF86AudioPlay,exec, playerctl play-pause"
          ",XF86AudioNext,exec, playerctl next"
          ",XF86AudioPrev,exec, playerctl previous"
          ",XF86AudioStop,exec, playerctl stop"

          "$mainMod, mouse_down, workspace, e-1"
          "$mainMod, mouse_up, workspace, e+1"

          # clipboard manager
          "$mainMod, V, exec, cliphist list | rofi -dmenu -theme-str 'window {width: 50%;} listview {columns: 1;}' | cliphist decode | wl-copy"

          # 添加重启 Hyprland 的快捷键
          "$mainMod SHIFT, R, exec, hyprctl dispatch exit" # 完全退出 Hyprland
          "$mainMod ALT, R, exec, hyprctl reload" # 重新加载配置
        ];
    };
  };
}
