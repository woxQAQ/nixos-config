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
  nix.package = pkgs.lix;
  environment.systemPackages = with pkgs; [
    ollama
    git-status
  ];
}
