{pkgs,stateVersion,username, ...}: {
  networking.hostName = "wsl"; # Define your hostname.
  system.stateVersion = stateVersion;
  wsl = {
    enable = true;
    defaultUser=username;
    startMenuLaunchers = true;
  };
  nixpkgs = {
    config = {
      allowUnfree = true;
    };
  };
  programs.git.config = {
    user.name=username;
    user.gmail="woxqaq@gmail.com";
  };
  environment.systemPackages = with pkgs;[
    go_1_23
    treefmt
    gopls
    delve
    go-tools
  ];
}
