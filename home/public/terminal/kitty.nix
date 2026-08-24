{
  pkgs,
  config,
  lib,
  ...
}:
let
  cfg = config.modules.public.terminal;
  inherit (pkgs.stdenv.hostPlatform) isDarwin;
  # nixpkgs wraps kitty.app's executable with a C binary wrapper (to extend PATH
  # for kittens). On macOS this breaks LaunchServices' pid binding:
  # NSRunningApplication.processIdentifier becomes -1 for LaunchServices-launched
  # instances, making kitty invisible to AeroSpace and other AX-based tools.
  # Undo the wrapper; its PATH additions are re-injected via `environment` below.
  kittyPackage =
    if isDarwin then
      pkgs.runCommand "kitty-${pkgs.kitty.version}-unwrapped" { meta = pkgs.kitty.meta or { }; } ''
        cp -RP ${pkgs.kitty} $out
        chmod -R u+w $out
        macos="$out/Applications/kitty.app/Contents/MacOS"
        if [ -e "$macos/.kitty-wrapped" ]; then
          rm "$macos/kitty"
          mv "$macos/.kitty-wrapped" "$macos/kitty"
        fi
      ''
    else
      pkgs.kitty;
in
{
  config = lib.mkIf (cfg.emulator == "kitty") {
    programs.kitty = {
      enable = true;
      package = kittyPackage;
      environment = lib.mkIf isDarwin {
        # same PATH suffix the nixpkgs wrapper used to inject
        PATH = "\${PATH}:${kittyPackage}/bin:${pkgs.imagemagick}/bin:${pkgs.ncurses.dev}/bin";
      };
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
        # background_opacity = "0.93";
        enable_audio_bell = false;
        tab_bar_edge = "top";

        shell = "${pkgs.bash}/bin/bash --login -c 'nu --login --interactive'";
      };
    };
  };
}
