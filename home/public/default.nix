{ ... }:
{
  imports = [
    ./desktop
    ./dev
    ./helix
    ./neovim
    ./shell
    ./terminal

    ./catppuccin.nix
    ../../pkg/dbeaver-bin/module.nix
    ./git.nix
    ./gh.nix
    ./mutable-config.nix
    ./options.nix
    ./playwright.nix
    ./shell_core.nix
    ./ssh.nix
    ./yazi.nix
  ];
}
