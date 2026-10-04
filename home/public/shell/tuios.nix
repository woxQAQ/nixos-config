{
  config,
  pkgs,
  tuios,
  mylib,
  dotfilesDir,
  ...
}:
let
  # Tests bind to loopback (pprof listen tests), which the Nix sandbox forbids.
  tuiosPkg = tuios.packages.${pkgs.stdenv.hostPlatform.system}.tuios.overrideAttrs {
    doCheck = false;
  };
in
{
  home.packages = [ tuiosPkg ];

  xdg.configFile."tuios/config.toml".source = mylib.mkMutable dotfilesDir config ./tuios.toml;

  programs.nushell.extraConfig = /* nu */ ''
    # auto start tuios
    if $nu.is-interactive and (not ("TUIOS_SESSION" in $env)) {
      let session = if ("KITTY_WINDOW_ID" in $env) { "kitty" } else { "main" }
      ^tuios attach $session -c
    }
  '';
}
