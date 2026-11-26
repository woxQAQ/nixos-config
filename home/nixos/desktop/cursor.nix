{ pkgs, ... }:
{
  # home.packages = with pkgs; [
  #   comixcursors
  # ];
  home.pointerCursor = {
    enable = true;
    gtk.enable = true;
    x11.enable = true;
    # Ice variant: white fill with black outline, high contrast on both
    # dark and light backgrounds. Amber is the yellow alternative.
    name = "Bibata-Modern-Ice";
    package = pkgs.bibata-cursors;
    size = 28;
  };
}
