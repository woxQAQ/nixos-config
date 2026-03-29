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
  services.openssh.enable = true;

  environment.systemPackages = with pkgs; [
    helix
    wget
    file
    fastfetch
    pciutils
    git
    git-lfs
    gitui
  ];

  system.stateVersion = stateVersion;
}
