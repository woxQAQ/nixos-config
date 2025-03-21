{
  self,
  nixpkgs,
  ...
} @ inputs: let
  system = "x86_64-linux";
  inherit (inputs.nixpkgs) lib;
  stateVersion = "24.11";
  specialArgs =
    inputs
    // {
      username = "woxQAQ";
      inherit stateVersion;
      unstable-pkg = import inputs.nixpkgs-unstable {
        inherit system;
        config.allowUnfree = true;
      };
    };
  mylib = import ../lib {inherit nixpkgs;};
  args = {
    inherit
      mylib
      inputs
      lib
      specialArgs
      system
      ;
  };
  nixosSystems = {
    woxQAQ = import ./woxQAQ.nix args;
    wsl = import ./wsl.nix args;
  };

  nixosSystemsValues = builtins.attrValues nixosSystems;
in {
  debug_ = {inherit nixosSystems;};
  imports = [./pre-commit-hooks.nix];
  nixosConfigurations = lib.attrsets.mergeAttrsList (
    map (it: it.nixosConfigurations or {}) nixosSystemsValues
  );
}
