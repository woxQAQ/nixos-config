{ catppuccin, lib, ... }:
let
  upstream = catppuccin + "/modules";
  adapters = import ./ports.nix;
  keepUpstream =
    path:
    let
      base = lib.removeSuffix ".nix" (builtins.baseNameOf path);
      name = if base == "neovim" then "nvim" else base;
    in
    !(adapters ? ${name});
in
{
  imports = [
    (lib.modules.importApply (upstream + "/global.nix") {
      catppuccinModules =
        builtins.filter keepUpstream (
          import (upstream + "/home-manager/all-modules.nix")
        )
        ++ [ ./overrides.nix ];
    })
    ./runtime.nix
  ];

  options.catppuccin = {
    appearance = lib.mkOption {
      type = lib.types.enum [
        "static"
        "auto"
      ];
      default = "static";
      description = "Default appearance policy for the locally extended Catppuccin ports.";
    };
    lightFlavor = lib.mkOption {
      type = lib.types.enum [
        "latte"
        "frappe"
        "macchiato"
        "mocha"
      ];
      default = "latte";
      description = "Default light flavor; catppuccin.flavor remains the dark and static flavor.";
    };
  };
}
