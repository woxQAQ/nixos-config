{
  pkgs,
  lib,
  ...
}:
{
  # gtrash implements the freedesktop trash spec, so it manages the same
  # $HOME/.local/share/Trash that nushell's `rm` (always_trash) and gvfs
  # write to.
  home.packages = [ pkgs.gtrash ];

  # Permanently delete files that have been in the trash for over 30 days.
  # Linux only: systemd user timers are unavailable on darwin.
  systemd.user = lib.mkIf pkgs.stdenv.hostPlatform.isLinux {
    services.trash-prune = {
      Unit.Description = "Prune files trashed more than 30 days ago";
      Service = {
        Type = "oneshot";
        ExecStart = "${lib.getExe pkgs.gtrash} prune --day 30 --force";
      };
    };
    timers.trash-prune = {
      Unit.Description = "Daily trash pruning";
      Timer = {
        OnCalendar = "daily";
        # Catch up on runs missed while the machine was off.
        Persistent = true;
      };
      Install.WantedBy = [ "timers.target" ];
    };
  };
}
