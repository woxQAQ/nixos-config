{ pkgs, config, ... }:
{
  home.packages = with pkgs; [
    lxappearance
    # libsForQt5.qt5ct
    gtk3
    gtk4
  ];

  xresources.properties = {
    # Align Xft DPI with the primary output's 1.25 scale.
    "Xft.dpi" = 120;
    "*.dpi" = 120;
  };

  home.sessionVariables = {
    XCURSOR_SIZE = "16";
  };

  catppuccin.gtk.icon.enable = false;

  gtk = {
    enable = true;

    font = {
      name = "Inter Noto Sans SC";
      package = pkgs.inter-noto-sans-sc;
      size = 12;
    };

    gtk2.configLocation = "${config.xdg.configHome}/gtk-2.0/gtkrc";

    iconTheme = {
      package = pkgs.adwaita-icon-theme;
      name = "Adwaita";
    };
  };
}
