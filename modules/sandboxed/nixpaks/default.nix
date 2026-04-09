{
  pkgs,
  nixpak,
  ...
}:
let
  args = {
    mkNixpak = nixpak.lib.nixpak {
      inherit (pkgs) lib;
      inherit pkgs;
    };
  };
  wrapper = _pkgs: path: (_pkgs.callPackage path args);
in
{
  nixpkgs.overlays = [
    (_: super: {
      nixpaks = {
        qq = wrapper super ./qq.nix;
      };
    })
  ];
}
