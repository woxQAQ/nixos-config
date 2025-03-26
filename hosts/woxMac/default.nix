{
  system,
  pkgs,
  ...
}: {
  environment.systemPackages = with pkgs; [
    mihomo-party
  ];

  networking = {
    hostName = "woxMac";
  };
  system.stateVersion = 5;
  nixpkgs = {
    hostPlatform = system;
    config = {
      allowUnfree = true;
    };
  };
}
