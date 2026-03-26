{
  system,
  username,
  hostname ? username,
  inputs,
  stateVersion,
  mylib,
  ...
}:
let
  valuesPath = ../hosts/${hostname}/values.nix;
  hostValues = if builtins.pathExists valuesPath then import valuesPath else { };
  mkPkgs =
    nixpkgs:
    import nixpkgs {
      inherit system;
      config.allowUnfree = true;
    };
in
inputs
// {
  inherit
    system
    username
    hostname
    stateVersion
    mylib
    hostValues
    ;
  unstable-pkg = mkPkgs inputs.nixpkgs-unstable;
  fastest-pkg = mkPkgs inputs.nixpkgs-fast;
  stable-pkg = mkPkgs inputs.nixpkgs-stable;
}
