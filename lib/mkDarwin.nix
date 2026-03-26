{
  inputs,
  lib,
  system ? "aarch64-darwin",
  username,
  hostname,
  stateVersion,
  mylib,
  home-modules ? [ ],
  darwin-modules,
  ...
}:
let
  inherit (inputs) nix-darwin home-manager;
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
nix-darwin.lib.darwinSystem {
  inherit system specialArgs;
  modules =
    darwin-modules
    ++ [
      {
        _module.args = {
          inherit inputs;
        };
      }
      (_: {
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
