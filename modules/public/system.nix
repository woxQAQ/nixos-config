{
  inputs,
  lib,
  pkgs,
  ...
}:
{

  # faster rebuilding
  documentation = {
    doc.enable = false;
    info.enable = false;
    man.enable = lib.mkDefault true;
  };
  nix = {
    nixPath = [ "nixpkgs=${inputs.nixpkgs}" ];
    registry = lib.pipe inputs [
      (lib.filterAttrs (_: lib.isType "flake"))
      (lib.mapAttrs (_: flake: { inherit flake; }))
      (
        x:
        x
        // {
          nixpkgs.flake =
            if pkgs.stdenv.hostPlatform.isLinux then inputs.nixpkgs else inputs.nixpkgs-unstable;
        }
      )
      (x: if pkgs.stdenv.hostPlatform.isDarwin then lib.removeAttrs x [ "nixpkgs-unstable" ] else x)
    ];
    settings = {
      auto-optimise-store = pkgs.stdenv.hostPlatform.isLinux;
      experimental-features = [
        "nix-command"
        "flakes"
        "ca-derivations"
        "dynamic-derivations"
        "pipe-operators"
      ];
      builders-use-substitutes = true;

      flake-registry = "/etc/nix/registry.json";
      sandbox = true;
      # mkForce: platform defaults (nix-darwin/NixOS) would otherwise
      # concat as duplicate list entries on top of this list.
      substituters = lib.mkForce [
        "https://mirrors.ustc.edu.cn/nix-channels/store"
        "https://cache.nixos.org"
        "https://nix-community.cachix.org"
        "https://nixpkgs-unfree.cachix.org"
        "https://cache.numtide.com"
      ];

      trusted-public-keys = lib.mkForce [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "nixpkgs-unfree.cachix.org-1:hqvoInulhbV4nJ9yJOEr+4wxhDV4xq2d1DK7S6Nj6rs="
        "niks3.numtide.com-1:DTx8wZduET09hRmMtKdQDxNNthLQETkc/yaX7M4qK0g="
      ];
    };
  };
}
