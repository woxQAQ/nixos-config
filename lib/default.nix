{ lib, ... }:
{
  mkHost = import ./mkhost.nix;
  mkDarwin = import ./mkDarwin.nix;
  scanPath =
    path:
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
  # Out-of-store symlink into the dotfiles checkout: lets an application
  # rewrite its own config while the file stays tracked in this repo.
  # `path` is a path literal relative to the calling file (e.g.
  # ./settings.json); resolving it against the flake source recovers the
  # repo-relative path, so typos and missing files fail at evaluation time.
  # Existence on the target machine is verified at activation time by
  # home/public/mutable-config.nix (pure evaluation cannot access
  # absolute paths).
  mkMutable =
    dotfilesDir: config: path:
    let
      root = toString ../.;
      abs = toString path;
      rel = lib.removePrefix "${root}/" abs;
    in
    assert lib.assertMsg (lib.hasPrefix "${root}/" abs)
      "mkMutable: ${abs} is not inside the flake source tree; pass a path literal inside this repo";
    config.lib.file.mkOutOfStoreSymlink "${dotfilesDir}/${rel}";
  iswsl =
    config:
    if builtins.hasAttr "wsl" config then
      (if builtins.hasAttr "enable" config.wsl then config.wsl.enable else false)
    else
      false;
}
