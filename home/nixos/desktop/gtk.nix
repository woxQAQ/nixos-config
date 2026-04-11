{ pkgs, ... }:
{
  home.packages = with pkgs; [
    lxappearance-gtk2
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
  gtk = {
    enable = true;

    font = {
      name = "Noto Sans";
      package = pkgs.noto-fonts;
      size = 12;
    };

    gtk3.extraConfig = {
      gtk-xft-antialias = 1;
      gtk-xft-hinting = 1;
      gtk-xft-hintstyle = "hintslight";
      gtk-xft-rgba = "none";
    };

    gtk2.force = true;

    # gtk3.extraConfig = {
    #   "gtk-application-prefer-dark-theme" = "1";
    # };
    # gtk4.extraConfig = {
    #   "gtk-application-prefer-dark-theme" = "1";
    # };
    # iconTheme = {
    #   # package = pkgs.adwaita-icon-theme;
    #   # name = "Adwaita";
    #   package = pkgs.papirus-icon-theme;
    #   name = "Papirus-Dark";
    # };
  };
}
