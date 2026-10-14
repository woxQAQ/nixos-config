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
    helix = {
      enable = lib.mkEnableOption "helix";
    };
    playwright = {
      enable = lib.mkEnableOption "playwright";
    };
    tuios = {
      enable = (lib.mkEnableOption "tuios") // {
        default = true;
      };
    };
    terminal = {
      emulators = lib.mkOption {
        type = lib.types.listOf (
          lib.types.enum [
            "kitty"
            "alacritty"
            "ghostty"
          ]
        );
        default = [ "kitty" ];
        description = "The terminal emulators to install and configure.";
      };
      font-family = lib.mkOption {
        type = lib.types.str;
        description = "The font family to use in the terminal emulator.";
        default = "Maple Mono NF CN";
      };
      font-family-fallbacks = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        description = "Fallback font families, used only by emulators supporting fallback chains (ghostty).";
        default = [ ];
      };
      font-size = lib.mkOption {
        type = lib.types.int;
        description = "The font size to use in the terminal emulator.";
        default = 14;
      };
    };
  };
}
