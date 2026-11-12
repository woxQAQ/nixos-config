{
  config,
  lib,
  pkgs,
  username,
  utils,
  ...
}:
let
  # Disko describes only the data disks; use that inventory for SMART as well.
  raidDisks = map (disk: disk.device) (
    builtins.attrValues config.disko.devices.disk
  );
  smartDisks = [ "/dev/disk/by-id/ata-CT500MX500SSD1_2204E60275CF" ] ++ raidDisks;
  laptopDisk = config.disko.devices.disk.toshibaLaptop.device;
  dataServices =
    lib.genAttrs
      [
        "qbittorrent-nox"
        "samba-smbd"
        "jellyfin"
        "sftpgo"
      ]
      (_: {
        unitConfig.RequiresMountsFor = [ "/mnt/data" ];
        bindsTo = [ "mnt-data.mount" ];
        requires = [ "storage-directories.service" ];
        after = [
          "mnt-data.mount"
          "storage-directories.service"
        ];
      });
  storageDirectories = pkgs.writeText "selfcloud-storage-tmpfiles.conf" ''
    d /mnt/data 0755 ${username} users -
    d /mnt/data/1000 0755 ${username} users -
    d /mnt/data/1000/videos 0755 ${username} users -
    d /mnt/data/1000/data 0755 ${username} users -
    d /mnt/data/1000/sftpgo 0755 ${username} users -
    a /mnt/data/1000 - - - - group::r-x,default:group::r-x
    a /mnt/data/1000/videos - - - - group::r-x,default:group::r-x
    a /mnt/data/1000/data - - - - group::r-x,default:group::r-x
  '';

  storageAlert = pkgs.writeShellScript "storage-alert" ''
    message="''${SMARTD_MESSAGE:-$*}"
    ${pkgs.util-linux}/bin/logger -p daemon.warning -t storage-alert -- "$message"
    ${pkgs.util-linux}/bin/wall -- "$message"
  '';
in
{
  boot.swraid = {
    enable = true;
    mdadmConf = ''
      ARRAY /dev/md0 UUID=c2747d59-3c21-4097-fa97-a8e527cdb632
      PROGRAM ${storageAlert}
    '';
  };
  services.lvm.enable = true;
  boot.initrd = {
    services.lvm.enable = true;
    availableKernelModules = [
      "dm_mod"
    ];
  };
  # Keep SSH available without the array, but stop data consumers with its mount.
  systemd.services = dataServices // {
    storage-directories = {
      description = "Initialize NAS directories on the mounted data filesystem";
      wantedBy = [ "multi-user.target" ];
      unitConfig.RequiresMountsFor = [ "/mnt/data" ];
      bindsTo = [ "mnt-data.mount" ];
      after = [ "mnt-data.mount" ];
      onFailure = [ "storage-alert@%n.service" ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        ExecStart = "${pkgs.systemd}/bin/systemd-tmpfiles --create ${storageDirectories}";
      };
    };

    storage-disk-power = {
      description = "Set sustained-operation power policy for the laptop HDD";
      wantedBy = [ "multi-user.target" ];
      requires = [ "${utils.escapeSystemdPath laptopDisk}.device" ];
      after = [ "${utils.escapeSystemdPath laptopDisk}.device" ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        ExecStart = "${pkgs.hdparm}/sbin/hdparm -B 254 -S 0 ${laptopDisk}";
      };
      onFailure = [ "storage-alert@%n.service" ];
    };

    "storage-alert@" = {
      description = "Report a failed storage maintenance unit";
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${storageAlert} Storage maintenance failed: %i";
      };
    };

    # The packaged mdcheck units reference /usr/share/mdadm/mdcheck, which is
    # unavailable on NixOS. Run a check (never a repair) through the MD sysfs API.
    storage-raid-check = {
      description = "Check RAID5 parity on md0";
      onFailure = [ "storage-alert@%n.service" ];
      path = [ pkgs.coreutils ];
      serviceConfig = {
        Type = "oneshot";
        TimeoutStartSec = "24h";
        TimeoutStopSec = "1min";
        Nice = 19;
        IOSchedulingClass = "idle";
      };
      script = ''
        set -euo pipefail
        md=/sys/block/md0/md
        if [[ $(< "$md/degraded") != 0 || $(< "$md/sync_action") != idle ]]; then
          echo "RAID check refused: md0 is degraded or already synchronizing" >&2
          exit 1
        fi

        cancel_check() {
          if [[ $(< "$md/sync_action") == check ]]; then
            printf 'idle\n' > "$md/sync_action"
          fi
        }
        trap cancel_check EXIT
        trap 'exit 1' TERM INT

        printf 'check\n' > "$md/sync_action"
        while [[ $(< "$md/sync_action") == check ]]; do
          sleep 30
        done

        if [[ $(< "$md/degraded") != 0 || $(< "$md/sync_action") != idle ]]; then
          echo "RAID state changed during the check" >&2
          exit 1
        fi
        mismatches=$(< "$md/mismatch_cnt")
        echo "RAID check completed: mismatch_cnt=$mismatches"
        [[ "$mismatches" == 0 ]]
      '';
    };

    "btrfs-scrub@".onFailure = [ "storage-alert@%n.service" ];
  };

  systemd.timers.storage-raid-check = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "*-*-01 02:00:00";
      AccuracySec = "1min";
      # Avoid starting a full-array scan immediately after deployment or boot.
      Persistent = false;
    };
  };

  services.smartd = {
    enable = true;
    autodetect = false;
    notifications = {
      mail.enable = false;
      wall.enable = false;
      x11.enable = false;
    };
    defaults.monitored = "-a -m <nomailer> -M exec ${storageAlert}";
    # Short tests run on the 5th, 12th, 19th and 26th, staggered by hour.
    # Long tests run on separate days (22nd–25th), away from both scrubs.
    devices = lib.imap0 (index: device: {
      inherit device;
      options = "-s (S/../(05|12|19|26)/./0${toString (index + 1)}|L/../${toString (22 + index)}/./02)";
    }) smartDisks;
  };

  services.btrfs.autoScrub = {
    enable = true;
    fileSystems = [ "/mnt/data" ];
    interval = "*-*-15 02:00:00";
    limit = "30M";
  };
  systemd.timers."btrfs-scrub@".timerConfig = {
    AccuracySec = lib.mkForce "1min";
    Persistent = lib.mkForce false;
  };

  services.udev.extraRules = ''
    ACTION=="add|change", KERNEL=="sd[a-z]", ATTR{queue/rotational}=="1", ATTR{queue/scheduler}="bfq"
  '';
  environment.systemPackages = with pkgs; [
    mdadm
    lvm2
    btrfs-progs
    smartmontools
  ];
}
