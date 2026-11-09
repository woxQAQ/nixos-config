{ config, ... }:
{
  imports = [
    ./nu.nix
    ./zellij.nix
    ./starship.nix
    ./zsh.nix
    ./tuios.nix
  ];

  home.sessionPath = [
    "${config.home.homeDirectory}/.local/bin"
    "${config.home.homeDirectory}/go/bin"
    "${config.home.homeDirectory}/.cargo/bin"
    "${config.home.homeDirectory}/.npm/bin"
  ];
}
