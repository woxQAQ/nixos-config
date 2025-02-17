{
  stateVersion,
  nixpkgs-unstable,
  ...
}:
{
  imports = [
    ./hardware-configuration.nix
    ./boot.specified.nix
    ../../modules/base.nix
    ../../modules/linux_x86_64
  ];
  networking.hostName = "woxQAQ"; # Define your hostname.
  hardware.graphics.enable = true;
  system.stateVersion = stateVersion;
  nixpkgs = {
    config = {
      allowUnfree = true;
    };
  };
}
