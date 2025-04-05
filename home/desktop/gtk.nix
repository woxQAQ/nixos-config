{pkgs, ...}: {
  home.packages = with pkgs; [
    lxappearance-gtk2
    libsForQt5.qt5ct
    catppuccin
    gtk3
    gtk4
  ];

  # set dpi for 4k monitor
  xresources.properties = {
    # dpi for Xorg's font
    "Xft.dpi" = 150;
    # or set a generic dpi
    "*.dpi" = 150;
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
      gtk-xft-rgba = "rgb";
    };

    gtk2.extraConfig = ''
      gtk-xft-antialias=1
      gtk-xft-hinting=1
      gtk-xft-hintstyle="hintslight"
      gtk-xft-rgba="rgb"
    '';

    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.papirus-icon-theme;
    };

    theme = {
      name = "catppuccin-macchiato-pink-compact";
      package = pkgs.catppuccin-gtk.override {
        accents = ["pink"];
        size = "compact";
        variant = "macchiato";
      };
    };
  };
}
