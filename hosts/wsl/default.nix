{pkgs,stateVersion, ...}: {
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
  environment.systemPackages = with pkgs;[
    go_1_23
    treefmt
    gopls
    delve
    go-tools
  ];
}
