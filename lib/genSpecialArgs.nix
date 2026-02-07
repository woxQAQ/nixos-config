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
  claude-code-pkg = import inputs.nixpkgs-claude-code {
    inherit system;
    config.allowUnfree = true;
  };
  zed-pkg = import inputs.nixpkgs-zed {
    inherit system;
    config.allowUnfree = true;
  };
  openclaw-pkg = import inputs.nixpkgs-openclaw {
    inherit system;
    config.allowUnfree = true;
    overlays = [
      inputs.nix-openclaw.overlays.default
    ];
  };
  geoip-pkg = import inputs.nixpkgs-geoip {
    inherit system;
  };
  stable-pkg = import inputs.nixpkgs {
    inherit system;
    config = {
      allowUnfree = true;
    };
  };
}
// lib.optionalAttrs hasValues { inherit hostValues; }
