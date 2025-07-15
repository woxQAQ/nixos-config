{
  pkgs,
  stateVersion,
  username,
  unstable-pkg,
  inputs,
  ...
}:
{
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
    linuxKernel.packages.linux_xanmod_latest.perf
    unstable-pkg.go-tools
    unstable-pkg.rustc
    unstable-pkg.rust-analyzer
    unstable-pkg.cargo
    unstable-pkg.rustfmt
    unstable-pkg.clippy
    uv
    buf
    nodejs
    nodePackages.npm
    nodePackages.prettier
    yarn
    nodePackages.pnpm
  ];
}
