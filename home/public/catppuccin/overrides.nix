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
      options,
      ...
    }@args:
    let
      path =
        catppuccin
        + "/modules/home-manager/${if name == "nvim" then "neovim" else name}.nix";
      original = (import path { inherit catppuccinLib; }) args;
      cfg = config.catppuccin.${name};
      automatic =
        cfg.appearance == "auto"
        && (!adapter.runtime || pkgs.stdenv.hostPlatform.isLinux);
      program = if name == "nvim" then "neovim" else name;
      programEnabled = name == "nvim" || (config.programs.${program}.enable or false);
    in
    original
    // {
      _file = toString ./ports.nix;
      options = lib.recursiveUpdate original.options {
        catppuccin.${name} = {
          appearance = lib.mkOption {
            type = lib.types.enum [
              "static"
              "auto"
            ];
            default = config.catppuccin.appearance;
            description = "Whether this port follows the system or terminal appearance.";
          };
          lightFlavor = lib.mkOption {
            type = catppuccinLib.types.flavor;
            default = config.catppuccin.lightFlavor;
            description = "Catppuccin flavor used in light mode.";
          };
        }
        // lib.optionalAttrs (name == "nvim") {
          implementation = lib.mkOption {
            type = lib.types.enum [
              "neovim"
              "nixvim"
            ];
            default = "neovim";
            description = "Neovim configuration provider receiving the theme settings.";
          };
        };
      };
      config = lib.mkMerge [
        (lib.mkIf (
          !automatic && !(name == "nvim" && cfg.implementation == "nixvim")
        ) original.config)
        (lib.mkIf
          (
            !automatic
            && name == "nvim"
            && cfg.implementation == "nixvim"
            && config.catppuccin.enable
            && cfg.enable
          )
          (
            lib.optionalAttrs (options.programs ? nixvim) {
              programs.nixvim.colorschemes.catppuccin.settings.flavour = cfg.flavor;
            }
          )
        )
        (lib.mkIf
          (automatic && config.catppuccin.enable && cfg.enable && programEnabled)
          (
            adapter.configure {
              inherit
                config
                lib
                pkgs
                options
                cfg
                catppuccinLib
                ;
              runtimePath = "${config.xdg.configHome}/catppuccin/current";
            }
          )
        )
      ];
    };
in
{
  imports = lib.mapAttrsToList wrap adapters;
}
