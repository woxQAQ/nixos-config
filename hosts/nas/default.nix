{
  stateVersion,
  pkgs,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
  ];

  networking = {
    networkmanager.enable = true;
    hostName = "selfcloud";
  };
  hardware.graphics.enable = true;
  boot.kernelPackages = pkgs.linuxPackages_xanmod_latest;
  system.stateVersion = stateVersion;
  services.xserver = {
    enable=true;
    xkb.layout="us";
    desktopManager = {
      xfce.enable=true;
      xterm.enable = false;
    };
    displayManager.defaultSession = "xfce";
  };
  nixpkgs = {
    config = {
      allowUnfree = true;
    };
  };
}
