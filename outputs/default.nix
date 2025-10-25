{
  nixpkgs,
  flake-parts,
  ...
}@inputs:
flake-parts.lib.mkFlake { inherit inputs; } {
  systems = [
    "x86_64-linux"
    "aarch64-darwin"
  ];

  imports = [
    flake-parts.flakeModules.partitions
  ];

  partitions.dev = {
    module = ./dev;
    extraInputsFlake = ./dev;
  };

  partitionedAttrs = nixpkgs.lib.genAttrs [
    "checks"
    "devShells"
    "formatter"
  ] (_: "dev");

  flake =
    let
      inherit (inputs.nixpkgs) lib;
      mylib = import ../lib { inherit lib; };
      args = {
        inherit
          mylib
          inputs
          lib
          ;
      };
      nixosSystems = {
        woxQAQ = import ./woxQAQ.nix (
          args
          // {
            system = "x86_64-linux";
            stateVersion = "25.05";
            hostname = "woxQAQ@nixos-x64-i5";
          }
        );
        wsl = import ./wsl.nix (
          args
          // {
            system = "x86_64-linux";
            stateVersion = "25.05";
          }
        );
      };

      darwinSystems = {
        woxDarwin = import ./woxDarwin.nix (
          args
          // {
            system = "aarch64-darwin";
            stateVersion = 5;
          }
        );
      };

      nixosSystemsValues = builtins.attrValues nixosSystems;
      darwinSystemsValues = builtins.attrValues darwinSystems;
    in
    {
      debug_ = { inherit nixosSystems; };
      nixosConfigurations = lib.attrsets.mergeAttrsList (
        map (it: it.nixosConfigurations or { }) nixosSystemsValues
      );

      darwinConfigurations = lib.attrsets.mergeAttrsList (
        map (it: it.darwinConfigurations or { }) darwinSystemsValues
      );
    };
}
