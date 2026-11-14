{
  config,
  lib,
  pkgs,
  ...
}:
let
  enabled = lib.any (
    package: lib.getName package == "tuicr"
  ) config.home.packages;
  inherit (config) catppuccin;
  toml = pkgs.formats.toml { };
in
{
  xdg.configFile."tuicr/config.toml" = lib.mkIf (enabled && catppuccin.enable) {
    source = toml.generate "tuicr-config.toml" (
      if catppuccin.appearance == "auto" then
        {
          appearance = "system";
          theme_light = "catppuccin-${catppuccin.lightFlavor}";
          theme_dark = "catppuccin-${catppuccin.flavor}";
        }
      else
        {
          theme = "catppuccin-${catppuccin.flavor}";
        }
    );
  };

  programs.nushell.extraConfig =
    lib.mkIf (config.programs.nushell.enable && enabled) # nu
      ''
        use ${./completions.nu} *
      '';
}
