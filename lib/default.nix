{ nixpkgs, ... }:
{
  mkHost = import ./mkhost.nix;
  imports = [ ./scanPath.nix ];
}
