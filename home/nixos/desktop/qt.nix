{ config, ... }:
let
  qtctSettings = qtct: {
    Appearance = {
      custom_palette = true;
      color_scheme_path = "${config.xdg.configHome}/${qtct}/colors/noctalia.conf";
      style = "Fusion";
      icon_theme = "Adwaita";
    };
  };
in
{
  # Noctalia owns the palette; qtct supplies it to both Qt generations.
  catppuccin.kvantum.enable = false;
  qt = {
    enable = true;
    platformTheme.name = "qtct";
    style.name = "Fusion";
    qt5ctSettings = qtctSettings "qt5ct";
    qt6ctSettings = qtctSettings "qt6ct";
  };
}
