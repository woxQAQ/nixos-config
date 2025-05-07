{
  inputs,
  lib,
  system ? "x86_64-linux",
  username,
  mylib,
  stateVersion,
  home-modules ? [],
  nixos-modules,
  desktop ? null,
  ...
}: let
  inherit (inputs) nixpkgs home-manager;
  genSpecialArgs = import ./genSpecialArgs.nix;
  specialArgs = genSpecialArgs {
    inherit inputs system username stateVersion mylib;
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

          home-manager.extraSpecialArgs = specialArgs;
          home-manager.users.${username}.imports = home-modules;
        }
      ]);
  }
