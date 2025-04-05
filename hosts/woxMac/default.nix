{
  system,
  ...
}: {
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
