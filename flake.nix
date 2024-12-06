{
  description = "woxQAQ's NixOS flake";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager/release-24.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    nix-vscode-extensions.url = "github:nix-community/nix-vscode-extensions";
    flake-schemas.url = "github:DeterminateSystems/flake-schemas";

    neovim-flake = {
      #url = git+file:///home/gvolpe/workspace/neovim-flake;
      url = "github:gvolpe/neovim-flake";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-schemas.follows = "flake-schemas";
    };
    hypr-binds-flake = {
      url = "github:hyprland-community/hypr-binds";
      inputs.nixpkgs.follows = "nixpkgs";
      # submodules = true;
    };
    hyprland.url = "github:hyprwm/Hyprland";
    # nix-gaming.url = "github:fufexan/nix-gaming";
    nur.url = "github:nix-community/NUR";
    hypr-contrib.url = "github:hyprwm/contrib";
  };
  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      ...
    }@inputs:
    let
      username = "woxQAQ";
      host = "woxQAQ";
      system = "x86_64-linux";
    in
    {
      nixosConfigurations = {
        ${username} = nixpkgs.lib.nixosSystem {
          specialArgs = { inherit inputs; };
          # specialArgs = {inherit inputs;};
          inherit system;
          modules = [
            ./configuration.nix
            home-manager.nixosModules.home-manager
            {
              home-manager.users.${username} = import ./home-manager;
              home-manager.extraSpecialArgs = {
                inherit
                  inputs
                  username
                  host
                  ;
              };
              home-manager.useUserPackages = true;
              home-manager.useGlobalPkgs = true;
            }
          ];
        };
      };
    };
}
