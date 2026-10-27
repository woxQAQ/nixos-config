{ manifest, upstream }:
let
  installed = builtins.fromJSON (builtins.readFile manifest);
  packages = (builtins.getFlake upstream).packages.${installed.system};
in
{
  versions = builtins.mapAttrs (
    name: current:
    let
      package = packages.${name};
    in
    {
      inherit (package) version;
      changelog = package.meta.changelog or "";
      newer = builtins.compareVersions package.version current.version > 0;
    }
  ) installed.packages;
}
