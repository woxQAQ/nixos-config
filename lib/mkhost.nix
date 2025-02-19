{
  inputs,
  lib,
  system ? "x86_64-linux",
  username,
  home-modules,
  nixos-modules,
  specialArgs,
  desktop ? null,
  ...
}:
let
  inherit (inputs) nixpkgs home-manager;
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
          inherit inputs username;
          inherit (specialArgs) stateVersion nur-ryan4yin unstable-pkg;

        };
        home-manager.users.${username}.imports = home-modules;
      }
    ]);

}
