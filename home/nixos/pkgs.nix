{ pkgs, ... }:
{
  home.packages = with pkgs; [
    # koodo-reader
    nixpaks.qq
    bwraps.wechat
  ];

  programs.zathura = {
    enable = true;
    options = {
      selection-clipboard = "clipboard";
      window-title-basename = true;
    };
  };
}
