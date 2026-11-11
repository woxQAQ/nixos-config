{ flake }:
let
  inherit (flake.inputs.nixpkgs) lib;
  hosts = flake.nixosConfigurations // flake.darwinConfigurations;
  defaults = {
    developer = true;
    workstation = false;
    zed = false;
    neovim = false;
    helix = false;
    playwright = false;
    cloudNative = false;
    tuios = true;
    terminal = [ ];
    fontFamily = "Ioskeley ChillRound Mono";
    fontSize = 14;
  };
  ghostty = defaults // {
    workstation = true;
    zed = true;
    neovim = true;
    helix = true;
    playwright = true;
    cloudNative = true;
    terminal = [ "ghostty" ];
    fontSize = 15;
  };
  cases = {
    selfcloud = defaults // {
      developer = false;
      tuios = false;
    };
    wsl = defaults;
    windows-vm1 = defaults // {
      workstation = true;
      terminal = [ "kitty" ];
    };
    woxQAQ = ghostty;
    woxMac = ghostty // {
      fontFamily = "IoskeleyMonoTerm Nerd Font Mono";
    };
    woxMac-m1 = ghostty // {
      neovim = false;
      playwright = false;
      cloudNative = false;
      fontFamily = "IoskeleyMonoTerm Nerd Font Mono";
    };
  };
  check =
    name: host: expected:
    let
      users = builtins.attrValues host.config.home-manager.users;
      home = builtins.head users;
      packages = map (package: package.pname or package.name) home.home.packages;
      actual = {
        go = home.programs.go.enable;
        rust = lib.elem "rustc" packages;
        node = lib.elem "nodejs" packages;
        direnv = home.programs.direnv.enable;
        dbeaver = home.programs.dbeaver.enable;
        zed = home.programs.zed-editor.enable;
        neovim = home.programs.nixvim.enable;
        helix = home.programs.helix.enable;
        playwright = home.modules.public.playwright.enable;
        cloudNative = home.modules.public.cloud-native.enable;
        tuios = home.modules.public.tuios.enable;
        ffmpeg = lib.elem "ffmpeg-full" packages;
        imagemagick = lib.elem "imagemagick" packages;
        graphviz = lib.elem "graphviz" packages;
        terminal = home.modules.public.terminal.emulators;
        kitty = home.programs.kitty.enable;
        ghostty = home.programs.ghostty.enable;
        alacritty = home.programs.alacritty.enable;
        fontFamily = home.modules.public.terminal.font-family;
        fontSize = home.modules.public.terminal.font-size;
        fontFallbacks = home.modules.public.terminal.font-family-fallbacks;
      };
      wanted = {
        inherit (expected)
          zed
          neovim
          helix
          playwright
          cloudNative
          tuios
          terminal
          fontFamily
          fontSize
          ;
        go = expected.developer;
        rust = expected.developer;
        node = expected.developer;
        direnv = expected.developer;
        dbeaver = expected.workstation;
        ffmpeg = expected.workstation;
        imagemagick = expected.workstation;
        graphviz = expected.developer;
        kitty = lib.elem "kitty" expected.terminal;
        ghostty = lib.elem "ghostty" expected.terminal;
        alacritty = lib.elem "alacritty" expected.terminal;
        fontFallbacks = [ ];
      };
    in
    assert builtins.length users == 1;
    assert lib.assertMsg (
      actual == wanted
    ) "${name}: expected ${builtins.toJSON wanted}, got ${builtins.toJSON actual}";
    assert
      home.programs.git.enable
      && home.programs.nushell.enable
      && home.programs.yazi.enable;
    assert lib.all (package: lib.elem package packages) [
      "nixd"
      "nixfmt"
      "nh"
    ];
    assert lib.hasInfix "min-release-age=2" home.home.file.".npmrc".text;
    assert lib.hasInfix "minimumReleaseAge: 2880"
      home.xdg.configFile."pnpm/config.yaml".text;
    # Evaluate generated files and Home Manager assertions without activating a system.
    assert builtins.isString home.home.activationPackage.drvPath;
    true;
  developerServer = hosts.selfcloud.extendModules {
    modules = [
      {
        home-manager.users.woxQAQ.imports = [
          "${flake.outPath}/home/public/profiles/developer.nix"
        ];
      }
    ];
  };
  workstationDefaults = hosts.wsl.extendModules {
    modules = [
      {
        home-manager.users.woxQAQ.imports = [
          "${flake.outPath}/home/public/profiles/workstation.nix"
        ];
      }
    ];
  };
  workstationNoTerminal = hosts.woxQAQ.extendModules {
    modules = [
      {
        home-manager.users.woxQAQ.modules.public.terminal.emulators = lib.mkForce [ ];
      }
    ];
  };
  serverHome = builtins.head (
    builtins.attrValues hosts.selfcloud.config.home-manager.users
  );
  serverPackages = map (
    package: package.pname or package.name
  ) serverHome.home.packages;
in
lib.mapAttrs (name: expected: check name hosts.${name} expected) cases
// {
  developerServer =
    assert lib.all (package: lib.elem package serverPackages) [
      "pi"
      "uv"
      "pnpm"
      "devenv"
      "ast-grep"
    ];
    assert developerServer.config.fileSystems == hosts.selfcloud.config.fileSystems;
    assert
      developerServer.config.services.gitea.settings
      == hosts.selfcloud.config.services.gitea.settings;
    check "developerServer" developerServer (
      cases.selfcloud // { developer = true; }
    );
  workstationDefaults = check "workstationDefaults" workstationDefaults (
    cases.wsl
    // {
      workstation = true;
      zed = true;
      terminal = [ "kitty" ];
    }
  );
  workstationNoTerminal = check "workstationNoTerminal" workstationNoTerminal (
    cases.woxQAQ // { terminal = [ ]; }
  );
}
