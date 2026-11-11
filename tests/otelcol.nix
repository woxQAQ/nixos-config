# Integration tests for modules/x86_64-linux/services/otelcol.nix.
#
# Run with:
#   nix eval --impure --json --expr 'import ./tests/otelcol.nix { flake = builtins.getFlake (toString ./.); }'
#
# Fixtures are minimal NixOS systems (no real host, no secrets); they only
# evaluate module composition, so nothing here proves a running collector —
# config validation happens at build time via `otelcol validate`.
{ flake }:
let
  inherit (flake.inputs.nixpkgs) lib;

  mkFixture =
    module:
    lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ../modules/x86_64-linux/services
        module
        {
          # The module's default package comes from our in-tree overlay.
          nixpkgs.overlays = builtins.attrValues (
            import ../overlays { inherit (flake) inputs; }
          );
          boot.loader.grub.enable = false;
          fileSystems."/" = {
            device = "/dev/invalid";
            fsType = "ext4";
          };
          system.stateVersion = "26.05";
        }
      ];
    };

  endpoints = {
    metrics = "http://selfcloud.lan:8428/opentelemetry/v1/metrics";
    logs = "http://selfcloud.lan:9428/insert/opentelemetry/v1/logs";
    traces = "http://selfcloud.lan:10428/insert/opentelemetry/v1/traces";
  };

  disabled = mkFixture { };

  gateway = mkFixture {
    modules.services.otelcol = {
      enable = true;
      inherit endpoints;
    };
  };
  gatewaySettings = gateway.config.services.opentelemetry-collector.settings;

  logsOnly = mkFixture {
    modules.services.otelcol = {
      enable = true;
      endpoints.logs = endpoints.logs;
    };
  };
  logsOnlySettings = logsOnly.config.services.opentelemetry-collector.settings;

  publicGateway = mkFixture {
    modules.services.otelcol = {
      enable = true;
      listenAddress = "0.0.0.0";
      openFirewall = true;
      endpoints.traces = endpoints.traces;
    };
  };

  noEndpoint = mkFixture { modules.services.otelcol.enable = true; };

  expectedPipeline = signal: {
    receivers = [ "otlp" ];
    processors = [
      "memory_limiter"
      "batch"
    ];
    exporters = [ "otlphttp/${signal}" ];
  };
in
{
  disabled =
    assert lib.assertMsg (
      !disabled.config.services.opentelemetry-collector.enable
    ) "disabled: upstream collector must stay off";
    assert lib.assertMsg (
      !(disabled.config.systemd.services ? opentelemetry-collector)
    ) "disabled: no systemd unit may be registered";
    true;

  gateway =
    assert lib.assertMsg gateway.config.services.opentelemetry-collector.enable
      "gateway: upstream collector must be on";
    assert lib.assertMsg (
      gatewaySettings.receivers.otlp.protocols.grpc.endpoint == "127.0.0.1:4317"
      && gatewaySettings.receivers.otlp.protocols.http.endpoint == "127.0.0.1:4318"
    ) "gateway: OTLP receivers must bind loopback on 4317/4318 by default";
    assert lib.assertMsg (
      builtins.attrNames gatewaySettings.service.pipelines == [
        "logs"
        "metrics"
        "traces"
      ]
    ) "gateway: every configured signal must get a pipeline";
    assert lib.assertMsg
      (
        gatewaySettings.service.pipelines
        == lib.mapAttrs (signal: _: expectedPipeline signal) endpoints
      )
      "gateway: pipelines must be otlp -> memory_limiter -> batch -> otlphttp/<signal>";
    assert lib.assertMsg (
      gatewaySettings.exporters == lib.mapAttrs' (signal: url: {
        name = "otlphttp/${signal}";
        value.endpoint = url;
      }) endpoints
    ) "gateway: each signal must export to its own endpoint";
    assert lib.assertMsg (
      gatewaySettings.processors.memory_limiter.limit_mib == 256
    ) "gateway: memory_limiter must carry the configured limit";
    assert lib.assertMsg (
      !lib.elem 4317 gateway.config.networking.firewall.allowedTCPPorts
    ) "gateway: firewall must stay closed unless openFirewall is set";
    assert lib.assertMsg
      (lib.hasPrefix "otelcol-" gateway.config.services.opentelemetry-collector.package.name)
      "gateway: default package must be our minimal build";
    true;

  logsOnly =
    assert lib.assertMsg (
      builtins.attrNames logsOnlySettings.service.pipelines == [ "logs" ]
    ) "logsOnly: only the configured signal may get a pipeline";
    assert lib.assertMsg (
      builtins.attrNames logsOnlySettings.exporters == [ "otlphttp/logs" ]
    ) "logsOnly: no exporter may exist for unconfigured signals";
    true;

  publicGateway =
    assert lib.assertMsg (
      publicGateway.config.services.opentelemetry-collector.settings.receivers.otlp.protocols.grpc.endpoint
      == "0.0.0.0:4317"
    ) "publicGateway: listenAddress must reach the receiver config";
    assert lib.assertMsg (
      lib.sort builtins.lessThan publicGateway.config.networking.firewall.allowedTCPPorts
      == [
        4317
        4318
      ]
    ) "publicGateway: openFirewall must open both OTLP ports";
    true;

  noEndpointRejected =
    assert lib.assertMsg
      (
        !(builtins.tryEval (
          builtins.seq noEndpoint.config.system.build.toplevel.drvPath true
        )).success
      )
      "noEndpointRejected: enabling the gateway without any endpoint must fail evaluation";
    true;
}
