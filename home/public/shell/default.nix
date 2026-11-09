{ config, ... }:
{
  imports = [
    ./nu.nix
    ./starship.nix
    ./tuios.nix
    ./zellij.nix
    ./zsh.nix
  ];

  home.sessionPath = [
    "${config.home.homeDirectory}/.local/bin"
    "${config.home.homeDirectory}/go/bin"
    "${config.home.homeDirectory}/.cargo/bin"
    "${config.home.homeDirectory}/.npm/bin"
  ];
}
