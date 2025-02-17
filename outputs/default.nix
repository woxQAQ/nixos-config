{
  self,
  inputs,
  outputs,
  ...
}:
let
  lib = import ../lib {
    inherit
      self
      inputs
      outputs
      ;
  };
  inherit (lib) mkHost mkHome;
  username = "woxQAQ";
  stateVersion = "24.11";
in
{
  nixosConfigurations = {
    woxQAQ = mkHost {
      inherit username stateVersion;
      hostname = "woxQAQ";
      desktop = "hyprland";
    };
  };
  homeConfigurations = {
    "${username}" = mkHome {
      inherit username stateVersion;
      hostname = "woxQAQ";
      desktop = "hyprland";
    };
  };
  overlays = import ./overlays { inherit inputs; };
}
