{pkgs, ...}: {
  imports = [
    ./brew.nix
    ./user.nix
    ./system.nix
    ./security.nix
    ./fonts.nix
  ];
  nix.package = pkgs.nix;
  environment.systemPackages = with pkgs; [
    ollama
  ];
}
