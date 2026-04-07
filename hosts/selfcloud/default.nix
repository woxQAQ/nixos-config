{
  pkgs,
  stateVersion,
  ...
}:
{
  imports = [
    ./hardware-configuration.nix
    ./storage.nix
    ./nas.nix
  ];

  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

  networking.hostName = "selfcloud";
  time.timeZone = "Asia/Shanghai";
  services = {
    openssh.enable = true;
    prometheus.exporters.node = {
      enable = true;
      openFirewall = true;
      enabledCollectors = [
        "systemd"
        "processes"
      ];
    };
  };

  environment.systemPackages = with pkgs; [
    helix
    wget
    file
    fastfetch
    pciutils
    git
    git-lfs
    gitui
    unzip
    unar
    unrar
    gnutar
    gzip
  ];

  system.stateVersion = stateVersion;
}
