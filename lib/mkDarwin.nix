{
  inputs,
  lib,
  system ? "aarch64-darwin",
  username,
  hostname,
  stateVersion,
  home-modules ? [],
  darwin-modules,
  # specialArgs,
  ...
}: let
  inherit (inputs) nix-darwin home-manager nixpkgs-darwin;
  genSpecialArgs = import ./genSpecialArgs.nix;
  specialArgs =
    genSpecialArgs {
      inherit inputs system username stateVersion;
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
        ({lib, ...}: {
          nixpkgs.pkgs = import nixpkgs-darwin {inherit system;};
        })
      ]
      ++ (lib.optionals ((lib.lists.length home-modules) > 0) [
        home-manager.darwinModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.backupFileExtension = "hmbak";

          home-manager.extraSpecialArgs = {
            inherit inputs username system;
            inherit
              (specialArgs)
              nur-ryan4yin
              stable-pkg
              unstable-pkg
              ;
          };
          home-manager.users.${username}.imports = home-modules;
        }
      ]);
  }
