{
  pkgs,
  ...
}:
{
  xdg.configFile = {
    "fcitx5/profile" = {
      source = ./profile.conf;
      force = true;
    };
  };

  i18n.inputMethod = {
    enable = true;
    type = "fcitx5";
    fcitx5.waylandFrontend = true;
    fcitx5.addons = with pkgs; [
      fcitx5-rime
      fcitx5-configtool
      fcitx5-chinese-addons
      fcitx5-gtk
    ];
  };
}
