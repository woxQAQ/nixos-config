{
  mylib,
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
          ../modules/public/users.nix
        ];
      }
    );
  };
}
