{
  inputs,
  lib,
  system ? "x86_64-linux",
  username,
  hostname ? username,
  mylib,
  stateVersion,
  home-modules ? [ ],
  nixos-modules,
  ...
}:
let
  inherit (inputs) home-manager nixpkgs;
  genSpecialArgs = import ./genSpecialArgs.nix;
  overlaysFunctions = import ../overlays { inherit inputs; };
  specialArgs = genSpecialArgs {
    inherit
      inputs
      system
      username
      hostname
      stateVersion
      mylib
      ;
  };
in
nixpkgs.lib.nixosSystem {
  inherit system specialArgs;
  modules =
    nixos-modules
    ++ [
      {
        _module.args = {
          inherit inputs;
        };
      }
      {
        nixpkgs = {
          config.allowUnfree = true;
          overlays = builtins.attrValues overlaysFunctions;
        };
      }
    ]
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
