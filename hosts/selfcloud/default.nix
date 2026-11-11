{
  pkgs,
  stateVersion,
  username,
  ...
}:
{
  imports = [
    ./hardware-configuration.nix
    ./disko.nix
    ./storage.nix
    ./nas.nix
    ./gitea.nix
    ./resource.nix
    ./monitoring.nix
  ];

  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

  users.users.${username} = {
    home = "/home/${username}";
    isNormalUser = true;
    extraGroups = [ "wheel" ];
  };

  modules.public.helix.enable = false;

  # Keep an interactive terminal for the encrypted agenix identity.
  environment.variables.NIXOS_REBUILD_NO_SYSTEMD_RUN = "1";

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
