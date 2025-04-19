{nixpkgs, ...} @ inputs: let
  inherit (inputs.nixpkgs) lib;
  mylib = import ../lib {inherit nixpkgs;};
  args = {
    inherit
      mylib
      inputs
      lib
      ;
  };
  nixosSystems = {
    woxQAQ = import ./woxQAQ.nix (args // {system = "x86_64-linux";});
    wsl = import ./wsl.nix (args
      // {
        system = "x86_64-linux";
        stateVersion = "25.05";
      });
  };

  darwinSystems = {
    woxDarwin = import ./woxDarwin.nix (args
      // {
        system = "aarch64-darwin";
        stateVersion = 5;
      });
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
