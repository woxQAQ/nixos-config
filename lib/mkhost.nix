{
  inputs,
  lib,
  system ? "x86_64-linux",
  username,
  stateVersion,
  home-modules ? [],
  nixos-modules,
  desktop ? null,
  ...
}: let
  inherit (inputs) nixpkgs home-manager;
  genSpecialArgs = import ./genSpecialArgs.nix;
  specialArgs = genSpecialArgs {
    inherit system username stateVersion;
  };
in
  nixpkgs.lib.nixosSystem {
    inherit system specialArgs;
    modules =
      nixos-modules
      ++ (lib.optionals ((lib.lists.length home-modules) > 0) [
        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.backupFileExtension = "hmbak";

          home-manager.extraSpecialArgs = {
            inherit inputs username system;
            inherit
              (specialArgs)
              stateVersion
              nur-ryan4yin
              unstable-pkg
              anyrun
              ;
          };
          home-manager.users.${username}.imports = home-modules;
        }
      ]);
  }
