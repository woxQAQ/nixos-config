{nixpkgs, ...}: {
  mkHost = import ./mkhost.nix;
  mkDarwin = import ./mkDarwin.nix;
  genSpecialArgs = import ./genSpecialArgs.nix;
  imports = [./scanPath.nix];
}
