{
  mylib,
  ...
}@args:
let
  name = "windows-vm1";
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
          ../modules/x86_64-linux/packages
          ../modules/x86_64-linux/desktop
          ../modules/x86_64-linux/system
          ../modules/public
          {
            modules.desktop = {
              environment = "gnome";
              fcitx5.enable = true;
            };
          }
        ];
        home-modules = [
          ../home/nixos
          ../home/public
          ../home/desktop
        ];
      }
    );
  };
}
