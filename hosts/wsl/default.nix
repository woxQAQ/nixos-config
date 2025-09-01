{
  pkgs,
  stateVersion,
  username,
  unstable-pkg,
  ...
}:
{
  networking.hostName = "wsl"; # Define your hostname.
  system.stateVersion = stateVersion;
  wsl = {
    enable = true;
    defaultUser = username;
    startMenuLaunchers = true;
    # docker-desktop.enable = true;
  };
  virtualisation.docker.enable = true;
  nixpkgs = {
    config = {
      allowUnfree = true;
    };
  };
  programs.git.config = {
    user.name = username;
    user.gmail = "woxqaq@gmail.com";
  };
  programs.zsh = {
    enable = true;
    autosuggestions.enable = true;
    shellAliases = {
      grep = "rg --color=always";
      ip = "ip --color";
    };
  };
  environment.systemPackages = with pkgs; [
    gh
    golangci-lint
    kubernetes-helm
    go_1_23
    gopls
    delve
    protols
    kind
    linuxKernel.packages.linux_xanmod_latest.perf
    unstable-pkg.go-tools
    uv
    nodejs
    nodePackages.npm
    nodePackages.prettier
    yarn
    nodePackages.pnpm
  ];
}
