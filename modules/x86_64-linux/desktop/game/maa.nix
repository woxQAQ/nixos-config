{
  pkgs,
  unstable-pkg,
  config,
  lib,
  ...
}:
with lib;
let
  cfg = config.modules.desktop.game;
  # maa-cli dlopens MaaCore, so the CLI and the core must come from the same
  # package set: mixing channels breaks on glibc ABI drift between them.
  maa-core = unstable-pkg.maa-assistant-arknights;
  # maa-cli locates libMaaCore and resources relative to its own binary, so
  # its wrapper must point at our vendored core instead of the stale nixpkgs
  # one. The `Waydroid` connection preset (maa init) additionally starts/stops
  # the waydroid session around runs, which requires the waydroid CLI on PATH
  # provided by the module below.
  maa-cli = unstable-pkg.maa-cli.override { maa-assistant-arknights = maa-core; };
in
{
  config = mkIf cfg.maa.enable {
    # MAA drives an Arknights client running inside Waydroid over ADB.
    virtualisation.waydroid.enable = true;

    environment.systemPackages = [
      # Waydroid exposes ADB over TCP; adb is invoked both by users and by the
      # maa-cli wrapper (which already prefixes android-tools into its PATH).
      pkgs.android-tools
      maa-core
      maa-cli
    ];
  };
}
