{ nixpkgs, self, ... }:
let
  inherit (self) inputs;
  mkHost =
    name: system:
    nixpkgs.lib.nixosSystem {
      modules = [
        {
          networking.hostName = name;
          nixpkgs.hostPlatform = system;
        }
        ./${name}
      ];
      specialArgs = {
        inherit inputs;
        falke = self;
      };
    };
in
{
  woxQAQ = mkHost "woxQAQ" "x86_64-linux";
}
