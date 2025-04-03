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
    xkb.layout="us";
    desktopManager.xfce.enable=true;
  };
  nixpkgs = {
    config = {
      allowUnfree = true;
    };
  };
}
