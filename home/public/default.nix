{ ... }:
{
  imports = [
    ./helix
    ./dev
    ./desktop
    ./shell
    ./terminal
    ./neovim
    ./agents
    ./pkgs.nix
    ./git.nix
    ./options.nix
    ./yazi.nix
    ./ssh.nix
    ./shell_core.nix
    ./catppuccin.nix
    ./mutable-config.nix
  ];
}
