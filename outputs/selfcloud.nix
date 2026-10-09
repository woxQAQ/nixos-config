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
          inputs.disko.nixosModules.disko
          ../secrets/linux.nix
        ];
        home-modules = [
          ../home/nixos
          ../home/public
          ../home/agents
          ../hosts/${name}/home.nix
          {
            modules.public.tuios.enable = false;
            modules.public.helix.enable = true;
          }
        ];
      }
    );
  };
}
