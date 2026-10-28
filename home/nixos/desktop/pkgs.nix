{ pkgs, ... }:
{
  home.packages = with pkgs; [
    wev

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

  fonts.fontconfig.enable = false;
}
