{
  pkgs,
  config,
  lib,
  ...
}:
with lib;
let
  cfg = config.modules.desktop.game;
in
{
  config = mkIf cfg.maa.enable {
    # MAA drives an Arknights client running inside Waydroid over ADB.
    virtualisation.waydroid.enable = true;

    environment.systemPackages = [
      # Waydroid exposes ADB over TCP; adb is invoked both by users and by the
      # maa-cli wrapper (which already prefixes android-tools into its PATH).
      pkgs.android-tools
      pkgs.maa-assistant-arknights
      # Both are vendored in pkg/ (nixpkgs' MAA is stuck at 5.x, maa-cli at
      # 0.5.x); the maa-cli wrapper links the vendored core, and its
      # `Waydroid` connection preset (maa init) starts/stops the waydroid
      # session around runs.
      pkgs.maa-cli
    ];
  };
}
