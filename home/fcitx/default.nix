{
  pkgs,
  nur-ryan4yin,
  ...
}: {
  home.file.".local/share/fcitx5/themes".source = "${
    nur-ryan4yin.packages.${pkgs.system}.catppuccin-fcitx5
  }/src";

  xdg.configFile = {
    "fcitx5/profile" = {
      source = ./profile.conf;
      force = true;
    };
    "fcitx5/conf/classicui.conf".source = ./class.conf;
  };

  i18n.inputMethod = {
    enabled = "fcitx5";
    fcitx5.addons = with pkgs; [
      fcitx5-rime
      fcitx5-configtool
      fcitx5-chinese-addons
      fcitx5-gtk
    ];
  };
}
