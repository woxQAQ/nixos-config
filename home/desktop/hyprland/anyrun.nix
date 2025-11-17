{
  pkgs,
  ...
}:
{
  programs.anyrun = {
    enable = true;
    config = {
      # plugins = with anyrun.packages.${pkgs.system}; [
      #   applications
      #   randr
      #   rink
      #   shell
      #   symbols
      #   translate
      # ];

      plugins = [
        "${pkgs.anyrun}/lib/libapplications.so"
        "${pkgs.anyrun}/lib/librandr.so"
        "${pkgs.anyrun}/lib/librink.so"
        "${pkgs.anyrun}/lib/libshell.so"
        "${pkgs.anyrun}/lib/libsymbols.so"
        "${pkgs.anyrun}/lib/libtranslate.so"
      ];

      width.fraction = 0.3;
      x.fraction = 0.5;
      y.fraction = 0.05;
      hideIcons = false;
      ignoreExclusiveZones = false;
      layer = "overlay";
      hidePluginInfo = false;
      closeOnClick = true;
      showResultsImmediately = true;
      maxEntries = null;
    };
    extraConfigFiles = {
      "symbols.ron".source = ./conf/anyrun/symbols.ron;
      "applications.ron".source = ./conf/anyrun/app.ron;
    };
  };
  xdg.configFile."anyrun/style.css".source = ./conf/anyrun/style.css;
}
