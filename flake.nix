{
  description = "woxQAQ's NixOS flake";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    nix-gaming.url = "github:fufexan/nix-gaming";
    home-manager.url = "github:nix-community/home-manager/release-24.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    nix-vscode-extensions.url = "github:nix-community/nix-vscode-extensions";
    flake-schemas.url = "github:DeterminateSystems/flake-schemas";
    pre-commit-hooks = {
      url = "github:cachix/git-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    neovim-flake = {
      url = "github:gvolpe/neovim-flake";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-schemas.follows = "flake-schemas";
    };
    hypr-binds-flake = {
      url = "github:hyprland-community/hypr-binds";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    hyprland.url = "github:hyprwm/Hyprland";
    nur.url = "github:nix-community/NUR";
    hypr-contrib.url = "github:hyprwm/contrib";
    nur-ryan4yin.url = "github:ryan4yin/nur-packages";
    catppuccin.url = "github:catppuccin/nix";
  };
  outputs =
    { self, nixpkgs-unstable, ... }@inputs:
    import ./outputs {
      inherit self inputs;
      inherit (self) outputs;
    };
  # outputs =
  #   {
  #     self,
  #     nixpkgs,
  #     home-manager,
  #     nur-ryan4yin,
  #     ...
  #   }@inputs:
  #   let
  #     username = "woxQAQ";
  #     host = "woxQAQ";
  #     system = "x86_64-linux";
  #     pkgs-unstable = import inputs.nixpkgs-unstable {
  #       inherit system;
  #       config.allowUnfree = true;
  #     };
  #   in
  #   {
  #     nixosConfigurations = {
  #       woxQAQ = nixpkgs.lib.nixosSystem {
  #         specialArgs = {
  #           inherit
  #             inputs
  #             host
  #             username
  #             nur-ryan4yin
  #             pkgs-unstable
  #             ;
  #         };
  #         inherit system;
  #         modules = [ ./hosts/woxQAQ ];
  #       };
  #     };
  #   };
}
