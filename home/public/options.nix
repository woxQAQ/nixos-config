{ lib, ... }:
{
  options.modules.public = {
    cloud-native = {
      enable = lib.mkEnableOption "Cloud-native";
    };
    desktop = {
      enable = lib.mkEnableOption "Desktop";
    };
    neovim = {
      enable = lib.mkEnableOption "neovim";
    };
    terminal = lib.mkOption {
      type = lib.types.nullOr (
        lib.types.enum [
          "kitty"
          "alacritty"
          "foot"
        ]
      );
      default = "kitty";
    };
  };
}
