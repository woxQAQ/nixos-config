{
  description = "woxQAQ's NixOS flake";

  outputs = inputs: import ./outputs inputs;
  inputs = {
    # keep-sorted start block=yes newline_separated=yes
    # ...
    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
      inputs.darwin.follows = "nix-darwin";
    };

    catppuccin = {
      url = "github:catppuccin/nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };

    helix = {
      url = "github:woxQAQ/helix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hidpipe = {
      url = "github:woxQAQ/hidpipe";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    llm-agents = {
      url = "github:numtide/llm-agents.nix";
      # Do not add nixpkgs follows here: this flake moves with nixpkgs-unstable
      # HEAD and uses hooks (e.g. installAgentSkills) that our pinned nixpkgs
      # channels may not have yet.
    };

    nix-darwin = {
      url = "github:nix-darwin/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs-darwin";
    };

    nix-gaming = {
      url = "github:fufexan/nix-gaming";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-wsl = {
      url = "github:nix-community/NixOS-WSL";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixpak = {
      url = "github:nixpak/nixpak";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixpkgs = {
      # url = "github:NixOS/nixpkgs/18dd725c29603f582cf1900e0d25f9f1063dbf11";
      url = "github:nixos/nixpkgs/nixpkgs-unstable";
      # url = "github:NixOS/nixpkgs/master";
    };

    nixpkgs-darwin.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    nixpkgs-fast = {
      url = "github:nixos/nixpkgs/nixpkgs-unstable";
    };

    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-25.05";

    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    nixvim = {
      url = "github:nix-community/nixvim";
    };

    noctalia = {
      url = "github:noctalia-dev/noctalia-shell";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nu_scripts = {
      url = "github:nushell/nu_scripts";
      flake = false;
    };

    secrets = {
      url = "git+ssh://git@github.com/woxQAQ/nix-secrets.git?shallow=1";
      flake = false;
    };

    tuios = {
      url = "github:Gaurav-Gosain/tuios/v0.12.0";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    woxVim = {
      url = "github:woxQAQ/nixvim";
      # inputs.nixpkgs.follows = "nixpkgs";
    };

    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs = {
        # IMPORTANT: To ensure compatibility with the latest Firefox version, use nixpkgs-unstable.
        nixpkgs.follows = "nixpkgs-unstable";
        home-manager.follows = "home-manager";
      };
    };

    # keep-sorted end
  };

  # outputs = inputs: import ./outputs inputs;
}
