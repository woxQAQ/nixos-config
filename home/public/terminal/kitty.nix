{
  pkgs,
  config,
  lib,
  ...
}:
let
  cfg = config.modules.public.terminal;
in
{
  config = lib.mkIf (cfg.emulator == "kitty") {
    programs.kitty = {
      enable = true;
      keybindings = {
        "ctrl+shift+m" = "toggle_maximized";
        "ctrl+shift+f" = "show_scrollback";
      };
      font = {
        name = cfg.font-family;
        size = cfg.font-size;
      };
      darwinLaunchOptions = [ "--start-as=maximized" ];
      settings = {
        hide_window_decorations = "titlebar-and-corners";
        macos_show_window_title_in = "none";
        macos_option_as_alt = true;
        macos_quit_when_last_window_closed = true;
        strip_trailing_spaces = "smart";
        update_check_interval = 0;

        copy_on_select = "yes";
        tab_title_template = "{index}";
        active_tab_font_style = "normal";
        inactive_tab_font_style = "normal";
        tab_bar_style = "powerline";
        tab_powerline_style = "round";
        background_opacity = "0.93";
        enable_audio_bell = false;
        tab_bar_edge = "top";

        shell = "${pkgs.bash}/bin/bash --login -c 'nu --login --interactive'";
      };
    };
  };
}
