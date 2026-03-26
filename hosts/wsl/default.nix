{
  pkgs,
  stateVersion,
  username,
  unstable-pkg,
  ...
}:
{
  networking.hostName = "wsl";
  system.stateVersion = stateVersion;
  wsl = {
    enable = true;
    defaultUser = username;
    startMenuLaunchers = true;
  };
  virtualisation.docker.enable = true;
  nixpkgs = {
    config = {
      allowUnfree = true;
    };
  };
  programs.git.config = {
    user.name = username;
    user.email = "woxqaq@gmail.com";
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
    go
    wslu
    wsl-open
    dos2unix
    gopls
    delve
    protols
    kind
    unstable-pkg.go-tools
    uv
    nodejs
    nodePackages.npm
    nodePackages.prettier
    yarn
    nodePackages.pnpm
  ];
}
