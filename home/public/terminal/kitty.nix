{ pkgs, ... }:
{
  programs.kitty = {
    enable = true;
    keybindings = {
      "ctrl+shift+m" = "toggle_maximized";
      "ctrl+shift+f" = "show_scrollback";
    };
    font = {
      name = "Maple Mono NF CN";
      size = if pkgs.stdenv.isDarwin then 14 else 13;

    };
    darwinLaunchOptions = [ "--start-as=maximized" ];
    settings = {
      hide_window_decorations = "titlebar-and-corners";
      macos_show_window_title_in = "none";
      background_opacity = "0.93";
      macos_option_as_alt = true;
      enable_audio_bell = false;
      tab_bar_edge = "top";
      shell = "${pkgs.bash}/bin/bash --login -c 'nu --login --interactive'";
    };
  };
}
