{ pkgs, ... }:
{
  home.packages = with pkgs; [
    # koodo-reader
  ];

  programs.zathura = {
    enable = true;
    options = {
      selection-clipboard = "clipboard";
      window-title-basename = true;
    };
  };
}
