{
  inputs,
  lib,
  system ? "aarch64-darwin",
  username,
  hostname,
  stateVersion,
  mylib,
  home-modules ? [],
  darwin-modules,
  # specialArgs,
  ...
}: let
  inherit (inputs) nix-darwin home-manager;
  genSpecialArgs = import ./genSpecialArgs.nix;
  specialArgs =
    genSpecialArgs {
      inherit inputs system username stateVersion mylib;
    }
    // {
      inherit hostname;
    };
in
  nix-darwin.lib.darwinSystem {
    inherit system specialArgs;
    modules =
      darwin-modules
      ++ [
        ({lib, ...}: let
          overlaysFunctions = import ../overlays {inherit inputs;};
        in {
          nixpkgs = {
            hostPlatform = system;
            config.allowUnfree = true;
            overlays = builtins.attrValues overlaysFunctions;
          };
        })
      ]
      ++ (lib.optionals ((lib.lists.length home-modules) > 0) [
        home-manager.darwinModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.backupFileExtension = "hmbak";
          home-manager.extraSpecialArgs = specialArgs;
          home-manager.users.${username}.imports = home-modules;
        }
      ]);
  }
