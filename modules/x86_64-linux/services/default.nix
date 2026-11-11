{
  # Reusable service modules. Importing registers them only; every module
  # defaults to disabled and is enabled explicitly by hosts.
  imports = [
    ./monitoring
    ./otelcol.nix
  ];
}
