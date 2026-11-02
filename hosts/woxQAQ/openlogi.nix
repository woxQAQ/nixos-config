{
  config,
  pkgs,
  fastest-pkg,
  ...
}:
{
  services.hidpipe.openlogi = {
    enable = true;
    mouse = "MX Master 2S";
    basePackage = fastest-pkg.openlogi.overrideAttrs (old: {
      patches = (old.patches or [ ]) ++ [ ./openlogi-config-symlink.patch ];
      postPatch = (old.postPatch or "") + ''
        install -Dm644 ${./openlogi-init.rs} crates/openlogi-agent/src/bin/openlogi-init.rs
      '';
      postInstall = (old.postInstall or "") + ''
        install -Dm755 target/${pkgs.stdenv.hostPlatform.rust.cargoShortTarget}/release/openlogi-init "$out/bin/openlogi-init"
        ${pkgs.python3}/bin/python ${./tests/openlogi-init.py} "$out/bin/openlogi-init"
      '';
    });
  };

  # Resolve the initial profile's device key before the input owner starts.
  systemd.user.services.openlogi-agent.serviceConfig.ExecStartPre =
    "${config.services.hidpipe.openlogi.package}/bin/openlogi-init %h/.config/openlogi/config.toml";
}
