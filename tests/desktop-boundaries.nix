{ flake }:
let
  inherit (flake.inputs.nixpkgs) lib;
  environments = {
    gnome = {
      environment = "gnome";
      noctalia = false;
      hyprland = false;
      niri = false;
      session = false;
    };
    niri = {
      environment = "niri";
      noctalia = true;
      hyprland = false;
      niri = true;
      session = true;
    };
    hyprland = {
      environment = "hyprland";
      noctalia = false;
      hyprland = true;
      niri = false;
      session = true;
    };
    none = {
      environment = null;
      noctalia = false;
      hyprland = false;
      niri = false;
      session = false;
    };
  };
  check =
    name: expected:
    let
      host = flake.nixosConfigurations.windows-vm1.extendModules {
        modules = [
          {
            modules.desktop.environment = lib.mkForce expected.environment;
            # The checkout has no wallpaper assets; startup commands are outside this fixture.
            home-manager.users.woxQAQ.wayland.windowManager.hyprland.settings.exec-once =
              lib.mkForce
                [ ];
          }
        ];
      };
      home = host.config.home-manager.users.woxQAQ;
      packages = map (package: package.pname or package.name) home.home.packages;
      qtPalette = settings: {
        custom = settings.Appearance.custom_palette;
        path = settings.Appearance.color_scheme_path or null;
      };
      expectedPalette = qtct: {
        custom = expected.noctalia;
        path =
          if expected.noctalia then
            "${home.xdg.configHome}/${qtct}/colors/noctalia.conf"
          else
            null;
      };
      actual = {
        noctalia = home.programs.noctalia.enable;
        recordingTool = lib.elem "gpu-screen-recorder" packages;
        hyprshot = lib.elem "hyprshot" packages;
        hyprland = home.wayland.windowManager.hyprland.enable;
        waybar = home.programs.waybar.enable;
        mako = home.services.mako.enable;
        session = home.home.file ? ".wayland-session";
        niriConfig = home.xdg.configFile ? "niri/config.kdl";
        niriPolkit = home.systemd.user.services ? niri-flake-polkit;
        qt5 = qtPalette home.qt.qt5ctSettings;
        qt6 = qtPalette home.qt.qt6ctSettings;
      };
      wanted = {
        inherit (expected) noctalia hyprland session;
        recordingTool = expected.noctalia;
        hyprshot = expected.hyprland;
        waybar = expected.hyprland;
        mako = expected.hyprland;
        niriConfig = expected.niri;
        niriPolkit = expected.niri;
        qt5 = expectedPalette "qt5ct";
        qt6 = expectedPalette "qt6ct";
      };
    in
    assert lib.assertMsg (
      actual == wanted
    ) "${name}: expected ${builtins.toJSON wanted}, got ${builtins.toJSON actual}";
    assert home.gtk.enable && home.qt.enable && home.programs.mpv.enable;
    assert home.programs.firefox.enable && lib.elem "wl-clipboard" packages;
    # Force Home Manager's generated files and assertions for each full configuration.
    assert builtins.isString home.home.activationPackage.drvPath;
    true;
in
lib.mapAttrs check environments
