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
  tuiosPkg =
    tuios.packages.${pkgs.stdenv.hostPlatform.system}.tuios.overrideAttrs
      (old: {
        patches = (old.patches or [ ]) ++ [ ./host-color-scheme.patch ];
        doCheck = false;
        postBuild = (old.postBuild or "") + ''
          # Exercise appearance reports and OSC queries without binding sockets.
          (
            cd vt
            go test . -run '^(TestConform_ColorScheme|TestReportColorsAnswerOSC10And11|TestReportPaletteAnswersOSC4)' -count=1
          )
        '';
      });
in
{
  config = lib.mkIf config.modules.public.tuios.enable {
    home.packages = [ tuiosPkg ];

    xdg.configFile."tuios/config.toml".source =
      mylib.mkMutable dotfilesDir config
        ./tuios.toml;
  };
}
