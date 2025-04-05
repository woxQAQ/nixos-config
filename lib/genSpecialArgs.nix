{
  system,
  username,
  inputs,
  stateVersion,
  ...
}: (
  inputs
  // {
    inherit system username stateVersion;
    unstable-pkg = import inputs.nixpkgs-unstable {
      inherit system;
      config.allowUnfree = true;
    };
  }
)
