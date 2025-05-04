{
  system,
  username,
  inputs,
  stateVersion,
  mylib,
  ...
}:
inputs
// {
  inherit system username stateVersion mylib;
  unstable-pkg = import inputs.nixpkgs-unstable {
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
