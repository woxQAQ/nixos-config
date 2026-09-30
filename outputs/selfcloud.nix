{
  mylib,
  inputs,
  ...
}@args:
let
  name = "selfcloud";
in
{
  nixosConfigurations = {
    "${name}" = mylib.mkHost (
      args
      // {
        username = "woxQAQ";
        hostname = name;
        nixos-modules = [
          ../hosts/${name}
          ../modules/public
          inputs.agenix.nixosModules.default
          ../secrets/linux.nix
        ];
        home-modules = [
          ../home/nixos
          ../home/public
        ];
      }
    );
  };
}
