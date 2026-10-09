{
  pkgs,
  username,
  ...
}:
{
  boot.swraid = {
    enable = true;
    mdadmConf = ''
      ARRAY /dev/md0 UUID=c2747d59-3c21-4097-fa97-a8e527cdb632
      PROGRAM ${pkgs.coreutils}/bin/true
    '';
  };
  services.lvm.enable = true;
  boot.initrd = {
    services.lvm.enable = true;
    availableKernelModules = [
      "dm_mod"
    ];
  };
  systemd.tmpfiles.rules = [
    # 类型 路径 模式 用户 组 清理策略
    "d /mnt/data 0755 ${username} users -"
    # 修复 ACL：子目录 group 权限只有 --x，需要改为 r-x 才能让 users 组（jellyfin）读取。
    # 注意：tmpfiles 的 ACL 字段内多条规则必须用逗号分隔，空格会导致解析失败被静默忽略。
    "a /mnt/data/1000 - - - - group::r-x,default:group::r-x"
    "a /mnt/data/1000/videos - - - - group::r-x,default:group::r-x"
    "a /mnt/data/1000/data - - - - group::r-x,default:group::r-x"
  ];

  # HDD 使用 bfq 调度器，qbittorrent 的 IOSchedulingClass=idle 只有在 bfq 下才真正生效
  # （mq-deadline 不支持 ionice 调度级别）。
  services.udev.extraRules = ''
    ACTION=="add|change", KERNEL=="sd[a-z]", ATTR{queue/rotational}=="1", ATTR{queue/scheduler}="bfq"
  '';
  # /mnt/data 的挂载声明已迁移到 disko.nix（device 变为 /dev/<vg>/0，
  # LVM 名称稳定，与 by-uuid 等价）。
  environment.systemPackages = with pkgs; [
    mdadm
    lvm2
    btrfs-progs
    smartmontools
  ];
  # services.btrfs.autoScrub = {};
}
