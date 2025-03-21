{stateVersion, ...}: {
  networking.hostName = "wsl"; # Define your hostname.
  system.stateVersion = stateVersion;
  wsl = {
    enable = true;
    defaultUser="woxQAQ";
    startMenuLaunchers = true;
  };
  nixpkgs = {
    config = {
      allowUnfree = true;
    };
  };
}
