{ config, lib, ... }:
let
  qtctSettings = qtct: {
    Appearance = {
      custom_palette = config.programs.noctalia.enable;
      style = "Fusion";
      icon_theme = "Adwaita";
    }
    // lib.optionalAttrs config.programs.noctalia.enable {
      color_scheme_path = "${config.xdg.configHome}/${qtct}/colors/noctalia.conf";
    };
  };
in
{
  # Use Noctalia's palette when enabled, otherwise keep Fusion's built-in colors.
  catppuccin.kvantum.enable = false;
  qt = {
    enable = true;
    platformTheme.name = "qtct";
    style.name = "Fusion";
    qt5ctSettings = qtctSettings "qt5ct";
    qt6ctSettings = qtctSettings "qt6ct";
  };
}
