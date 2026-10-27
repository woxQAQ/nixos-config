{
  lib,
  ...
}:
{
  nix = {
    # nix-darwin's built-in launchd jobs replaced the fast-nix-gc flake
    # input; they run the stock `nix-store --gc` / `nix-store --optimise`.
    gc = {
      automatic = true;
      interval = [
        {
          Weekday = 0;
          Hour = 3;
          Minute = 15;
        }
      ];
      options = "--delete-older-than 7d";
    };
    optimise = {
      automatic = true;
      interval = [
        {
          Weekday = 0;
          Hour = 4;
          Minute = 15;
        }
      ];
    };
    settings = {
      allowed-impure-host-deps = [
        "/bin/sh"
        "/dev/random"
        "/dev/urandom"
        "/dev/zero"
        "/usr/bin/ditto"
        "/usr/lib/libSystem.B.dylib"
        "/usr/lib/libc.dylib"
        "/usr/lib/system/libunc.dylib"
      ];
      # buildDotnetModule emits __sandboxProfile on Darwin (mds, ICU,
      # SecurityServer); strict `sandbox = true` refuses such drvs
      # outright, so we normally run `relaxed` and sandbox everything else.
      #
      # Forced off for now: the GHSA hardening shipped in nix 2.34.9 / 2.35.3+
      # grows the Darwin sandbox profile with the build's input closure, and
      # darwin-system's ~1k inputs push it past macOS's 64 KiB profile limit
      # ("data object length ... exceeds maximum (65535)", NixOS/nix#16613).
      # Restore "relaxed" once the bucketing fix (NixOS/nix#16619) reaches a
      # released nix.
      sandbox = lib.mkForce false;

      extra-sandbox-paths = [
        "/System/Library/Frameworks"
        "/System/Library/PrivateFrameworks"
        "/usr/lib"
        "/usr/bin/env"
      ];
      auto-optimise-store = false;
    };
  };

  # We manage the `nixpkgs` flake registry entry ourselves (pointing at
  # `nixpkgs-unstable`, see modules/public/system.nix), so disable
  # nix-darwin's automatic pinning to the system nixpkgs to avoid a
  # conflicting `nix.registry.nixpkgs.to` definition.
  nixpkgs.flake = {
    setFlakeRegistry = false;
    # `setNixPath` requires `setFlakeRegistry`; `nix.nixPath` is already
    # set explicitly in modules/public/system.nix.
    setNixPath = false;
  };
}
