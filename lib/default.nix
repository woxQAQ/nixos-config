{nixpkgs, ...}: {
  mkHost = import ./mkhost.nix;
  mkDarwin = import ./mkDarwin.nix;
  imports = [./scanPath.nix];
}
