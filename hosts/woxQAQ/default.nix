{stateVersion, ...}: {
  imports = [
    ./hardware-configuration.nix
    ./boot.specified.nix
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
