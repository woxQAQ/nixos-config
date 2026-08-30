{
  lib,
  config,
  pkgs,
  fast-nix-gc,
  ...
}:
let
  mkNixJobWrapper =
    name: command:
    pkgs.writeShellScript name ''
      set +e
      export PATH=${lib.makeBinPath [ config.nix.package ]}:/usr/bin:/bin

      log() {
        printf '%s %s\n' "[$(/bin/date -u '+%FT%TZ')][${name}]" "$1"
      }

      log "starting"
      ${lib.escapeShellArgs command}
      status=$?
      log "finished status=$status"
      exit $status
    '';
  fastNixGc = fast-nix-gc.packages.${pkgs.stdenv.hostPlatform.system}.default;
  gcInterval = [
    {
      Weekday = 0;
      Hour = 3;
      Minute = 15;
    }
  ];
  gcWrapper = mkNixJobWrapper "nix-gc" (
    [
      "/usr/bin/caffeinate"
      "-i"
      "-s"
    ]
    ++ config.services.fast-nix-gc.argv
  );

  optimiseWrapper = mkNixJobWrapper "nix-optimise" (
    [
      "/usr/bin/caffeinate"
      "-i"
      "-s"
    ]
    ++ config.services.fast-nix-optimise.argv
  );

  nixJobLogPaths = {
    gc = {
      stdout = "/var/log/nix-gc.out.log";
      stderr = "/var/log/nix-gc.err.log";
    };
    optimise = {
      stdout = "/var/log/nix-optimise.out.log";
      stderr = "/var/log/nix-optimise.err.log";
    };
  };
in
{
  imports = [
    fast-nix-gc.darwinModules.default
  ];
  nix = {
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
      min-free = lib.mkForce (20 * 1024 * 1024 * 1024);
      max-free = lib.mkForce (50 * 1024 * 1024 * 1024);
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

  launchd.daemons = lib.mkIf config.nix.enable {
    fast-nix-gc.serviceConfig = {
      ProgramArguments = lib.mkForce [ "${gcWrapper}" ];
      StandardOutPath = nixJobLogPaths.gc.stdout;
      StandardErrorPath = nixJobLogPaths.gc.stderr;

      # Idle CPU + throttled disk I/O so maintenance yields to foreground
      # work instead of stalling the shared APFS container and tripping
      # the WindowServer watchdog.
      ProcessType = "Background";
      LowPriorityIO = true;
    };

    fast-nix-optimise.serviceConfig = {
      ProgramArguments = lib.mkForce [ "${optimiseWrapper}" ];
      StandardOutPath = nixJobLogPaths.optimise.stdout;
      StandardErrorPath = nixJobLogPaths.optimise.stderr;

      # Idle CPU + throttled disk I/O (see nix-gc); optimise scans ~2M
      # link inodes and was the worst APFS-contention offender.
      ProcessType = "Background";
      LowPriorityIO = true;
    };
  };

  services = lib.mkIf config.nix.enable {
    fast-nix-gc = {
      enable = true;
      automatic = true;
      package = fastNixGc;
      startCalendarInterval = gcInterval;
      deleteOlderThan = "7d";
      keepRecent = "7d";
    };

    fast-nix-optimise = {
      enable = true;
      automatic = true;
      startCalendarInterval = lib.map (entry: entry // { Hour = entry.Hour + 1; }) gcInterval;
    };
  };
}
