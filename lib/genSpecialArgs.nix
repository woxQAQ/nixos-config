{
  system,
  username,
  inputs,
  stateVersion,
  ...
}: (
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
