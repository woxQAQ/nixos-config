{ inputs, ... }:
let
  # Common nixpkgs configuration to reduce duplication
  mkNixpkgs =
    pkgs: system:
    import pkgs {
      inherit system;
      config.allowUnfree = true;
    };
in
{
  # Combined overlay that provides both master and unstable package sets
  unstable-packages = final: _prev: {
    master = mkNixpkgs inputs.master final.system;
    unstable = mkNixpkgs inputs.unstable final.system;
  };

  # Custom package overlay
  modifications = final: prev: {
    git-status = final.callPackage ../pkg/git-status { };
  };
}
