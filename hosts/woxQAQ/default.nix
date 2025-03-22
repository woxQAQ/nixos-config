{stateVersion,pkgs, ...}: {
  imports = [
    ./hardware-configuration.nix
    ./boot.specified.nix
    ./vm.nix
  ];

  environment.systemPackages = with pkgs; [
    mihomo-party
  ];

  networking = {
    networkmanager.enable = true;
    hostName = "woxQAQ";
    proxy = {
      httpProxy = "http://127.0.0.1:7890";
      httpsProxy = "http://127.0.0.1:7890";
    };
  };
  hardware.graphics.enable = true;
  system.stateVersion = stateVersion;
  nixpkgs = {
    config = {
      allowUnfree = true;
    };
  };
}
