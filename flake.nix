{
  description = "woxQAQ's NixOS flake";

  # nixConfig = {
  #   substituters = [
  #     "https://mirrors.ustc.edu.cn/nix-channels/store"
  #     "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store"
  #     "https://mirrors.sustech.edu.cn/nix-channels/store"
  #     "https://nix-community.cachix.org"
  #   ];
  #   trusted-public-keys = [
  #     "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
  #   ];
  # };

  outputs = inputs: import ./outputs inputs;
  inputs = {
    nixpkgs = {
      url = "github:NixOS/nixpkgs/nixos-unstable";
    };
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-24.11";
    nixos-wsl = {
      url = "github:nix-community/NixOS-WSL";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixpkgs-darwin.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    nix-darwin = {
      url = "github:lnl7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs-darwin";
    };
    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-gaming.url = "github:fufexan/nix-gaming";
    # nix-vscode-extensions.url = "github:nix-community/nix-vscode-extensions";
    flake-schemas.url = "github:DeterminateSystems/flake-schemas";

    pre-commit-hooks = {
      url = "github:cachix/git-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    agenix = {
      url = "github:ryantm/agenix";
      inputs = {
        nixpkgs.follows = "nixpkgs";
      };
    };

    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
    };

    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };

    anyrun = {
      url = "github:anyrun-org/anyrun";
      # inputs.nixpkgs.follows = "nixpkgs";
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

  # outputs = inputs: import ./outputs inputs;
}
