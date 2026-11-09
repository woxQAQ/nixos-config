{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.programs.dbeaver;
in
{
  options.programs.dbeaver = {
    drivers = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = [ ];
      example = lib.literalExpression "with pkgs; [ sqlite-jdbc ]";
      description = ''
        JDBC packages whose share/java JARs replace matching Maven libraries in
        DBeaver's built-in drivers. JARs must include Maven pom.properties metadata.
        Unmatched packages fail the build. Other driver libraries keep their defaults.
      '';
    };
    forceX11 = lib.mkOption {
      type = lib.types.bool;
      default = pkgs.stdenv.hostPlatform.isLinux;
      defaultText = lib.literalExpression "pkgs.stdenv.hostPlatform.isLinux";
      description = "Use XWayland on Linux to avoid inconsistent SWT widget sizes on Wayland.";
    };
    environment = lib.mkOption {
      type = lib.types.attrsOf (lib.types.nullOr lib.types.str);
      default = { };
      description = "Environment variables for DBeaver only. A null value unsets a variable.";
    };
    extraJavaOptions = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      example = [ "-Dswt.autoScale=200" ];
      description = "Additional JVM options appended to dbeaver.ini.";
    };
    showSplash = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Show the startup splash screen.";
    };
    package = lib.mkOption {
      apply =
        package:
        if cfg.enable && package != null then
          pkgs.callPackage ./. {
            dbeaver-bin = package;
            inherit (cfg)
              drivers
              forceX11
              environment
              extraJavaOptions
              showSplash
              ;
          }
        else
          package;
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.drivers == [ ] || cfg.package != null;
        message = "programs.dbeaver.drivers requires programs.dbeaver.package to be non-null.";
      }
    ];
  };
}
