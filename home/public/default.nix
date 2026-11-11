{ ... }:
{
  imports = [
    ./desktop
    ./dev/nix.nix
    ./dev/npm.nix
    ./helix
    ./neovim
    ./shell
    ./terminal

    ./catppuccin.nix
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
