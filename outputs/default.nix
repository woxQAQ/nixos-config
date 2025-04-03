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
    woxQAQ = import ./woxQAQ.nix args // {system = "x86_64-linux";};
    nas = import ./nas.nix args // {system="x86_64-linux";};
    wsl =
      import ./wsl.nix args
      // {
        system = "x86_64-linux";
        stateVersion = "25.05";
      };
  };

  darwinSystems = {
    woxDarwin =
      import ./woxDarwin.nix args
      // {
        system = "aarch64-darwin";
        stateVersion = "25.05";
      };
  };

  nixosSystemsValues = builtins.attrValues nixosSystems;
  darwinSystemsValues = builtins.attrValues darwinSystems;
in {
  debug_ = {inherit nixosSystems;};
  imports = [./pre-commit-hooks.nix];
  nixosConfigurations = lib.attrsets.mergeAttrsList (
    map (it: it.nixosConfigurations or {}) nixosSystemsValues
  );

  darwinConfigurations = lib.attrsets.mergeAttrsList (
    map (it: it.darwinConfigurations or {}) darwinSystemsValues
  );
}
