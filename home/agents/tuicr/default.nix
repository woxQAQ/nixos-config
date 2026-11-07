{ config, lib, ... }:
{
  programs.nushell.extraConfig =
    lib.mkIf
      (
        config.programs.nushell.enable
        && lib.any (package: lib.getName package == "tuicr") config.home.packages
      )
      ''
        use ${./completions.nu} *
      '';
}
