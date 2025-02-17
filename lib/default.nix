{ self, ... }:
let
  inherit (self) inputs outputs;
  inherit (inputs) nixpkgs home-manager;

  forAllSystem = nixpkgs.lib.genAttrs [
    "aarch64-linux"
    "i686-linux"
    "x86_64-linux"
    "aarch64-darwin"
    "x86_64-darwin"
  ];
  mkHome =
    {
      hostname,
      username,
      system ? "x86_64-linux",
      desktop ? null,
      stateVersion,
    }:
    home-manager.lib.homeManagerConfiguration {
      pkgs = nixpkgs.legacyPackages.${system};
      extraSpecialArgs = {
        inherit
          self
          inputs
          outputs
          hostname
          username
          stateVersion
          desktop
          ;
      };
      modules = [
        ../home
        {
          home = {
            inherit username stateVersion;
            homeDirectory = "/home/${username}";
          };
        }
      ];
    };
  mkHost =
    {
      hostname,
      username,
      desktop ? null,
      stateVersion,
    }:
    nixpkgs.lib.nixosSystem {
      modules = [
        {
          networking.hostName = hostname;
        }
        ../hosts/${username}
      ];
      specialArgs = {
        inherit
          inputs
          outputs
          stateVersion
          self
          hostname
          username
          desktop
          ;
      };
    };
in
{
  inherit mkHost forAllSystem mkHome;
}
