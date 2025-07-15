{ pkgs, ... }:
{
  imports = [
    ./fonts.nix
    ./security.nix
    ./system.nix
    ./user.nix
    ./brew.nix
    ./agenix.nix
  ];
  nix.package = pkgs.nix;
  environment.systemPackages = with pkgs; [
    ollama
    git-status
  ];
}
