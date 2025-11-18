{
  stateVersion,
  username,
  pkgs,
  ...
}:
{
  imports = [
    ./hardware-configuration.nix
  ];

  networking = {
    hostName = "windows-vm1";
  };
  # hardware.graphics = {
  #   enable = true;
  #   enable32Bit = true;
  # };
  boot.loader = {
    grub.device = "/dev/sda";
  };
  system.stateVersion = stateVersion;
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = true;
    };
  };
  nixpkgs = {
    config = {
      allowUnfree = true;
    };
  };
  users.users.${username}.shell = pkgs.nushell;
}
