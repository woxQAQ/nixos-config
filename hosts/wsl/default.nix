{
  pkgs,
  stateVersion,
  username,
  unstable-pkg,
  inputs,
  ...
}: {
  networking.hostName = "wsl"; # Define your hostname.
  system.stateVersion = stateVersion;
  wsl = {
    enable = true;
    defaultUser = username;
    startMenuLaunchers = true;
    docker-desktop.enable = true;
  };
  nixpkgs = {
    config = {
      allowUnfree = true;
    };
  };
  programs.git.config = {
    user.name = username;
    user.gmail = "woxqaq@gmail.com";
  };
  environment.systemPackages = with pkgs; [
    gh
    golangci-lint
    kubernetes-helm
    go_1_23
    treefmt
    gopls
    delve
    unstable-pkg.go-tools
    uv
  ];
}
