{
  system,
  username,
  inputs,
  stateVersion,
  mylib,
  lib,
  ...
}:
let
  valuesPath = ../hosts/${username}/values.nix;
  hasValues = builtins.pathExists valuesPath;
  hostValues = if hasValues then import valuesPath else { };
in
inputs
// {
  inherit
    system
    username
    stateVersion
    mylib
    ;
  unstable-pkg = import inputs.nixpkgs-unstable {
    inherit system;
    config.allowUnfree = true;
  };
  fastest-pkg = import inputs.nixpkgs-fast {
    inherit system;
    config.allowUnfree = true;
  };
  stable-pkg = import inputs.nixpkgs {
    inherit system;
    config = {
      allowUnfree = true;
    };
  };
}
// lib.optionalAttrs hasValues { inherit hostValues; }
