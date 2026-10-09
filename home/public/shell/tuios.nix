{
  config,
  lib,
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
  config = lib.mkIf config.modules.public.tuios.enable {
    home.packages = [ tuiosPkg ];

    xdg.configFile."tuios/config.toml".source = mylib.mkMutable dotfilesDir config ./tuios.toml;

    programs.nushell.extraConfig = /* nu */ ''
      # auto start tuios (kitty only)
      if $nu.is-interactive and ("KITTY_WINDOW_ID" in $env) and (not ("TUIOS_SESSION" in $env)) {
        ^tuios attach kitty -c
      }
    '';
  };
}
