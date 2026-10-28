{
  config,
  lib,
  ...
}:
let
  cfg = config.modules.btrbk;
in
{
  options.modules.btrbk = {
    enable = lib.mkEnableOption "btrbk snapshots of btrfs subvolumes";

    device = lib.mkOption {
      type = lib.types.str;
      default = config.fileSystems."/".device;
      defaultText = lib.literalExpression ''config.fileSystems."/".device'';
      description = ''
        Block device backing the btrfs filesystem to snapshot. Defaults to the
        device mounted at `/`, which is where our disko layouts put btrfs.
      '';
    };

    volumePath = lib.mkOption {
      type = lib.types.str;
      default = "/mnt/btr_pool";
      description = ''
        Where we mount the btrfs top-level subvolume (subvolid=5). btrbk only
        snapshots subvolumes that appear as directories below its `volume`,
        and our disko layouts never mount the top level, so we mount it here
        solely for btrbk.
      '';
    };

    subvolumes = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [
        "root"
        "home"
      ];
      description = ''
        Subvolume names (relative to the top level) to snapshot. `nix` is
        excluded on purpose: the store is reproducible and snapshots of it
        only waste space.
      '';
    };

    snapshotDir = lib.mkOption {
      type = lib.types.str;
      default = "btrbk_snapshots";
      description = ''
        Snapshot directory, relative to {option}`volumePath`. Created by btrbk
        on first run; kept as a plain directory on the top level so snapshots
        stay out of the snapshotted subvolumes themselves.
      '';
    };

    onCalendar = lib.mkOption {
      type = lib.types.str;
      default = "hourly";
      description = "systemd calendar for the snapshot timer.";
    };

    snapshotPreserveMin = lib.mkOption {
      type = lib.types.str;
      default = "18h";
      description = "Keep all snapshots for at least this long, regardless of `snapshotPreserve`.";
    };

    snapshotPreserve = lib.mkOption {
      type = lib.types.str;
      default = "48h 14d 8w";
      description = ''
        GFS-style retention: all snapshots for 48h, then one per day for 14
        days, then one per week for 8 weeks. See btrbk.conf(5).
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    # Mount the top level so `volumePath/root`, `volumePath/home`, ... resolve.
    # `nofail` keeps boot unblocked if the device is missing; a failed mount
    # surfaces as a failing btrbk timer instead of silently writing into the
    # root subvolume, because btrbk refuses non-subvolume `subvolume` paths.
    fileSystems.${cfg.volumePath} = {
      device = cfg.device;
      fsType = "btrfs";
      options = [
        "subvolid=5"
        "noatime"
        "nofail"
      ];
    };

    services.btrbk.instances.btrbk = {
      inherit (cfg) onCalendar;
      settings = {
        timestamp_format = "long";
        snapshot_preserve_min = cfg.snapshotPreserveMin;
        snapshot_preserve = cfg.snapshotPreserve;
        volume.${cfg.volumePath} = {
          snapshot_dir = cfg.snapshotDir;
          subvolume = lib.genAttrs cfg.subvolumes (_: { });
        };
      };
    };
  };
}
