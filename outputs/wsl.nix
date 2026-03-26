{
  mylib,
  inputs,
  ...
}@args:
let
  name = "wsl";
in
{
  nixosConfigurations = {
    "${name}" = mylib.mkHost (
      args
      // {
        username = "woxQAQ";
        hostname = name;
        nixos-modules = [
          inputs.nixos-wsl.nixosModules.wsl
          ../hosts/${name}
          ../modules/x86_64-linux/system
          ../modules/x86_64-linux/packages
          ../modules/public
        ];
        home-modules = [
          ../home/public
          ../home/nixos
        ];
      }
    );
  };
}
