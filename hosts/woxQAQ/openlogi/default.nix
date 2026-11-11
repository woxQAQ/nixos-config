{
  config,
  pkgs,
  ...
}:
{
  # The MX Master advertises keyboard capabilities; keyd's wildcard grabs it.
  # OpenLogi preserves this ID on its virtual mouse, so both stay outside keyd.
  services.keyd.keyboards.default.ids = [
    "*"
    "-046d:4069"
  ];

  # Pin capture to keyd so startup waits for its replacement virtual keyboard.
  services.hidpipe.keyboard = "keyd virtual keyboard";

  services.hidpipe.openlogi = {
    enable = true;
    gui.enable = true;
    mouse = "MX Master 2S";
    # Match the system graphics driver's libc when the GUI loads Vulkan ICDs.
    basePackage = pkgs.openlogi.overrideAttrs (old: {
      postPatch = (old.postPatch or "") + ''
        install -Dm644 ${./openlogi-init.rs} crates/openlogi-agent/src/bin/openlogi-init.rs
      '';
      postInstall = (old.postInstall or "") + ''
        install -Dm755 target/${pkgs.stdenv.hostPlatform.rust.cargoShortTarget}/release/openlogi-init "$out/bin/openlogi-init"
        ${pkgs.python3}/bin/python ${./openlogi-init.py} "$out/bin/openlogi-init"
      '';
    });
  };

  # Reopen the virtual keyboard when keyd's package or configuration changes.
  systemd.user.services.hidpipe = {
    restartTriggers = [
      config.services.keyd.package
      config.environment.etc."keyd/default.conf".source
    ];
  };

  # Keep capture lifecycle evidence for intermittent side-button loss.
  systemd.user.services.openlogi-agent.environment.OPENLOGI_LOG =
    "info,openlogi_hid::gesture=debug,openlogi_agent_core::watchers::gesture=debug,openlogi_agent_core::orchestrator=debug,openlogi_agent_core::remote=debug,openlogi_hook::linux=debug";

  # Resolve the initial profile's device key before the input owner starts.
  systemd.user.services.openlogi-agent.serviceConfig.ExecStartPre =
    "${config.services.hidpipe.openlogi.package}/bin/openlogi-init %h/.config/openlogi/config.toml";
}
