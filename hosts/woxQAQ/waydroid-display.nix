{ pkgs, ... }:
let
  waydroid60 = pkgs.writeShellApplication {
    name = "waydroid-60hz";
    runtimeInputs = [
      pkgs.waydroid
      pkgs.util-linux
    ];
    text = ''
      if [ "$#" -eq 0 ]; then
        set -- show-full-ui
      fi

      # Reuse the nested session when another launcher already owns it.
      exec 9>"$XDG_RUNTIME_DIR/waydroid-gamescope.lock"
      if ! flock --nonblock 9; then
        waydroid "$@"
        exit
      fi

      # The Wayland socket is selected at session startup, so migrate an
      # existing direct session before connecting to the nested compositor.
      waydroid session stop
      exec /run/wrappers/bin/gamescope \
        --backend wayland --expose-wayland \
        --nested-width 1920 --nested-height 1080 \
        --nested-refresh 60 --nested-unfocused-refresh 60 \
        -- waydroid "$@"
    '';
  };
in
{
  home.packages = [ waydroid60 ];

  xdg.desktopEntries = {
    Waydroid = {
      name = "Waydroid";
      genericName = "Android Container";
      comment = "Android with a dedicated 60 Hz display";
      exec = "${waydroid60}/bin/waydroid-60hz";
      icon = "waydroid";
      terminal = false;
      categories = [ "Utility" ];
      actions.stop = {
        name = "Stop Waydroid";
        exec = "${pkgs.waydroid}/bin/waydroid session stop";
      };
    };
  };
}
