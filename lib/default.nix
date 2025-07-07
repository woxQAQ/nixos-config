{lib, ...}: {
  mkHost = import ./mkhost.nix;
  mkDarwin = import ./mkDarwin.nix;
  scanPath = path:
    builtins.map (f: (path + "/${f}")) (
      builtins.attrNames (
        lib.attrsets.filterAttrs (
          path: _type:
            (_type == "directory") || ((path != "default.nix") && (lib.strings.hasSuffix ".nix" path))
        ) (builtins.readDir path)
      )
    );
  getDir = import ./getDir.nix;
  flakeRoot = lib.path.append ../.;
}
