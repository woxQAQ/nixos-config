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
      # outright. Relaxed still sandboxes everything else.
      sandbox = lib.mkForce "relaxed";

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
