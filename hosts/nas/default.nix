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
  nixpkgs = {
    config = {
      allowUnfree = true;
    };
  };
}
