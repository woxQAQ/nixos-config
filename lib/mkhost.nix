{
  inputs,
  lib,
  system ? "x86_64-linux",
  username,
  mylib,
  stateVersion,
  home-modules ? [ ],
  nixos-modules,
  hostname,
  ...
}:
let
  inherit (inputs) home-manager nixpkgs;
  genSpecialArgs = import ./genSpecialArgs.nix;
  specialArgs = genSpecialArgs {
    inherit
      inputs
      system
      username
      stateVersion
      hostname
      mylib
      ;
  };
in
nixpkgs.lib.nixosSystem {
  inherit system specialArgs;
  modules =
    nixos-modules
    ++ (lib.optionals ((lib.lists.length home-modules) > 0) [
      home-manager.nixosModules.home-manager
      {
        home-manager = {
          useGlobalPkgs = true;
          useUserPackages = true;
          backupFileExtension = "hmbak";

          extraSpecialArgs = specialArgs;
          users.${username}.imports = home-modules;
        };
      }
    ]);
}
