{
  description = "woxQAQ's NixOS flake";
  #
  # nixConfig = {
  #   extra-substituters = [
  #     "https://nix-community.cachix.org"
  #   ];
  #   extra-trusted-public-keys = [
  #     "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
  #   ];
  # };

  outputs = inputs: import ./outputs inputs;
  inputs = {
    # keep-sorted start block=yes newline_separated=yes
    # determinate.url = "https://flakehub.com/f/DeterminateSystems/determinate/*";
    #
    # aagl = {
    #   url = "github:ezKEa/aagl-gtk-on-nix";
    # };

    agenix = {
      url = "github:ryantm/agenix";
    };

    catppuccin = {
      url = "github:catppuccin/nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    dae = {
      url = "github:woxQAQ/dae-flake.nix/e2e3b0ddd4c6580803568d7127bc2fec18a7f0a7";
    };

    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-darwin = {
      url = "github:lnl7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs-darwin";
    };

    nix-gaming = {
      url = "github:fufexan/nix-gaming";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-openclaw = {
      url = "github:openclaw/nix-openclaw";
    };

    nixos-wsl = {
      url = "github:nix-community/NixOS-WSL";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixpkgs = {
      # url = "github:NixOS/nixpkgs/18dd725c29603f582cf1900e0d25f9f1063dbf11";
      url = "github:nixos/nixpkgs/nixpkgs-unstable";
      # url = "github:NixOS/nixpkgs/master";
    };

    # NOTE: use this input to a better claude code version control without affect other apps' version
    # when use a unified nixpkgs inputs.
    nixpkgs-claude-code = {
      url = "github:nixos/nixpkgs/nixpkgs-unstable";
    };

    nixpkgs-darwin.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    nixpkgs-geoip = {
      url = "github:nixos/nixpkgs/nixos-unstable";
    };

    nixpkgs-openclaw = {
      url = "github:nixos/nixpkgs/nixpkgs-unstable";
    };

    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-25.05";

    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    nixpkgs-zed = {
      url = "github:nixos/nixpkgs/nixpkgs-unstable";
    };

    noctalia = {
      url = "github:noctalia-dev/noctalia-shell";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nu_scripts = {
      url = "github:nushell/nu_scripts?shallow=1";
      flake = false;
    };

    secrets = {
      url = "git+ssh://git@github.com/woxQAQ/nix-secrets.git?shallow=1";
      flake = false;
    };

    vicinae.url = "github:vicinaehq/vicinae"; # tell Nixos where to get Vicinae

    woxVim = {
      url = "github:woxQAQ/nixvim";
      # inputs.nixpkgs.follows = "nixpkgs";
    };

    # keep-sorted end
  };

  # outputs = inputs: import ./outputs inputs;
}
