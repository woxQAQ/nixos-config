{ catppuccinLib }:
{ catppuccin, lib, ... }:
let
  adapters = import ./ports.nix;
  wrap =
    name: adapter:
    {
      config,
      lib,
      pkgs,
      ...
    }@args:
    let
      path = catppuccin + "/modules/home-manager/${name}.nix";
      original = (import path { inherit catppuccinLib; }) args;
      cfg = config.catppuccin.${name};
      automatic =
        cfg.appearance == "auto"
        && (!adapter.runtime || pkgs.stdenv.hostPlatform.isLinux);
      programEnabled = config.programs.${name}.enable or false;
      inherit (lib)
        recursiveUpdate
        mkOption
        types
        mkMerge
        mkIf
        ;
    in
    original
    // {
      _file = toString ./ports.nix;
      options = recursiveUpdate original.options {
        catppuccin.${name} = {
          appearance = mkOption {
            type = types.enum [
              "static"
              "auto"
            ];
            default = config.catppuccin.appearance;
            description = "Whether this port follows the system or terminal appearance.";
          };
          lightFlavor = mkOption {
            type = catppuccinLib.types.flavor;
            default = config.catppuccin.lightFlavor;
            description = "Catppuccin flavor used in light mode.";
          };
        };
      };
      config = mkMerge [
        (mkIf (!automatic) original.config)
        (mkIf (automatic && config.catppuccin.enable && cfg.enable && programEnabled) (
          adapter.configure {
            inherit
              config
              lib
              pkgs
              cfg
              catppuccinLib
              ;
            runtimePath = "${config.xdg.configHome}/catppuccin/current";
          }
        ))
      ];
    };
in
{
  imports = lib.mapAttrsToList wrap adapters;
}
