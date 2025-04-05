{
  system,
  username,
  stateVersion,
  ...
} @ inputs: (
  inputs
  // {
    inherit system;
    inherit username;
    unstable-pkg = import inputs.nixpkgs-unstable {
      inherit system;
      config.allowUnfree = true;
    };
  }
)
