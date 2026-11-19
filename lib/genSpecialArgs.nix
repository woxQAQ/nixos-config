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
  isDarwin = builtins.match ".*-darwin" system != null;
  # Location of this flake's working checkout on the target machine.
  # Override per host via `dotfilesDir` in hosts/<hostname>/values.nix when
  # the repo lives somewhere other than ~/nixos-config. Existence is verified
  # at activation time (pure evaluation cannot access absolute paths).
  dotfilesDir =
    hostValues.dotfilesDir
      or "${if isDarwin then "/Users" else "/home"}/${username}/nixos-config";
  mkPkgs =
    nixpkgs:
    import nixpkgs {
      inherit system;
      config.allowUnfree = true;
      # Keep the alternate channels consistent with the main package set, so
      # that mixing pkgs and unstable-pkg/fastest-pkg/stable-pkg at runtime
      # (e.g. maa-cli dlopening the vendored MaaCore) stays ABI-coherent
      # within each set.
      overlays = builtins.attrValues (import ../overlays { inherit inputs; });
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
    dotfilesDir
    ;
  unstable-pkg = mkPkgs inputs.nixpkgs-unstable;
  fastest-pkg = mkPkgs inputs.nixpkgs-fast;
  stable-pkg = mkPkgs inputs.nixpkgs-stable;
}
