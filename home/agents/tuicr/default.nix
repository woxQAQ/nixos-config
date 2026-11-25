{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (config) catppuccin;
  autoAppearance = catppuccin.appearance == "auto";
  useDesktopAppearance = autoAppearance && pkgs.stdenv.hostPlatform.isLinux;
  toml = pkgs.formats.toml { };
  appearanceConfig =
    appearance:
    toml.generate "tuicr-config.toml" {
      inherit appearance;
      theme_light = "catppuccin-${catppuccin.lightFlavor}";
      theme_dark = "catppuccin-${catppuccin.flavor}";
    };
in
{
  catppuccin.runtime.files."tuicr.toml" =
    lib.mkIf (catppuccin.enable && useDesktopAppearance)
      {
        light = appearanceConfig "light";
        dark = appearanceConfig "dark";
      };

  xdg.configFile."tuicr/config.toml" = lib.mkIf catppuccin.enable {
    source =
      if useDesktopAppearance then
        config.lib.file.mkOutOfStoreSymlink "${config.xdg.configHome}/catppuccin/current/tuicr.toml"
      else if autoAppearance then
        appearanceConfig "system"
      else
        toml.generate "tuicr-config.toml" {
          theme = "catppuccin-${catppuccin.flavor}";
        };
  };

  programs.nushell.extraConfig =
    lib.mkIf config.programs.nushell.enable # nu
      ''
        use ${./completions.nu} *
      '';
}
