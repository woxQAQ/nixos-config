{ lib, ... }:
{
  mkHost = import ./mkhost.nix;
  mkDarwin = import ./mkDarwin.nix;
  scanPath =
    path:
    map (f: (path + "/${f}")) (
      builtins.attrNames (
        lib.attrsets.filterAttrs (
          path: _type:
          (_type == "directory")
          || ((path != "default.nix") && (lib.strings.hasSuffix ".nix" path))
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
  # nixd workspace settings (the value of the `nixd` section) shared by the
  # neovim and helix configs. Option/package completion workers evaluate the
  # exprs below, so each `options` entry costs one evaluator process; we only
  # point at the primary editing machines (woxQAQ for NixOS + home-manager,
  # woxMac for nix-darwin) instead of every host in the flake.
  mkNixdSettings =
    dotfilesDir:
    let
      # `toString` because builtins.getFlake only accepts path values since
      # nix 2.35 (NixOS/nix#15290); nix-darwin hosts still run 2.34.x.
      flake = "(builtins.getFlake (toString ${dotfilesDir}))";
    in
    {
      # Complete packages from the nixpkgs pinned by this flake.
      nixpkgs.expr = "import ${flake}.inputs.nixpkgs { }";
      options = {
        nixos.expr = "${flake}.nixosConfigurations.woxQAQ.options";
        nix-darwin.expr = "${flake}.darwinConfigurations.woxMac.options";
        # home-manager runs as a NixOS module here, so dig its option set out
        # of the host's options instead of a standalone homeConfigurations.
        home-manager.expr = "${flake}.nixosConfigurations.woxQAQ.options.home-manager.users.type.getSubOptions []";
      };
    };
  iswsl =
    config:
    if builtins.hasAttr "wsl" config then
      (if builtins.hasAttr "enable" config.wsl then config.wsl.enable else false)
    else
      false;
}
