{
  inputs,
  lib,
  pkgs,
  self,
  ...
}:
let
  inherit (pkgs.stdenv.hostPlatform) isDarwin isLinux;
in
{
  # faster rebuilding
  documentation = {
    doc.enable = false;
    info.enable = false;
    man.enable = lib.mkDefault true;
  };
  environment.systemPackages = with pkgs; [
    git
    nix-prefetch-git
  ];
  environment.etc =
    with lib;
    mapAttrs' (
      name: input:
      nameValuePair "nix/inputs/${name}" {
        source = input.outPath or input;
      }
    ) inputs
    // optionalAttrs isLinux {
      "nixos".source = self;
    };
  nix = with lib; {
    package = pkgs.nixVersions.latest;
    nixPath = [ "nixpkgs=${inputs.nixpkgs}" ];
    registry = pipe inputs [
      (filterAttrs (_: isType "flake"))
      (mapAttrs (_: flake: { inherit flake; }))
      (
        x:
        x
        // {
          nixpkgs.flake = if isLinux then inputs.nixpkgs else inputs.nixpkgs-unstable;
        }
      )
      (x: if isDarwin then removeAttrs x [ "nixpkgs-unstable" ] else x)
    ];
    settings = {
      auto-optimise-store = isLinux;
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
      # Keep cache endpoints and signing trust together for all hosts.
      # The USTC mirror reuses cache.nixos.org signatures.
      # Override platform entries (priority 100) without duplicating them;
      # hosts can still replace the cache list with mkForce (priority 50).
      substituters = lib.mkOverride 90 [
        "https://mirrors.ustc.edu.cn/nix-channels/store"
        "https://cache.nixos.org"
        "https://nix-community.cachix.org"
        # Prebuilt packages from the llm-agents input.
        "https://cache.numtide.com"
        # Theme builds; disable the Home Manager cache injection.
        "https://catppuccin.cachix.org"
      ];

      trusted-public-keys = lib.mkForce [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "niks3.numtide.com-1:DTx8wZduET09hRmMtKdQDxNNthLQETkc/yaX7M4qK0g="
        "catppuccin.cachix.org-1:noG/4HkbhJb+lUAdKrph6LaozJvAeEEZj4N732IysmU="
      ];

      fallback = true;
      connect-timeout = 5;
      log-lines = 50;
      keep-going = true;
      use-xdg-base-directories = true;
    };
  };
}
