{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.modules.services.otelcol;

  # Signals with a configured endpoint each get their own pipeline and their
  # own otlphttp exporter instance, because the VictoriaMetrics family
  # exposes one OTLP ingestion endpoint per service.
  activeSignals = lib.filterAttrs (_: endpoint: endpoint != null) cfg.endpoints;

  exporterName = signal: "otlphttp/${signal}";

  settings = lib.recursiveUpdate {
    receivers.otlp.protocols = {
      grpc.endpoint = "${cfg.listenAddress}:${toString cfg.grpcPort}";
      http.endpoint = "${cfg.listenAddress}:${toString cfg.httpPort}";
    };

    processors = {
      # memory_limiter must stay the first processor in every pipeline.
      memory_limiter = {
        check_interval = "5s";
        limit_mib = cfg.memoryLimitMiB;
      };
      batch = { };
    };

    exporters = lib.mapAttrs' (signal: endpoint: {
      name = exporterName signal;
      value.endpoint = endpoint;
    }) activeSignals;

    service.pipelines = lib.mapAttrs (signal: _: {
      receivers = [ "otlp" ];
      processors = [
        "memory_limiter"
        "batch"
      ];
      exporters = [ (exporterName signal) ];
    }) activeSignals;
  } cfg.extraSettings;
in
{
  options.modules.services.otelcol = {
    enable = lib.mkEnableOption "minimal OpenTelemetry collector acting as an OTLP gateway";

    package = lib.mkPackageOption pkgs "otelcol" { };

    endpoints = {
      metrics = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        example = "http://selfcloud.lan:8428/opentelemetry/v1/metrics";
        description = ''
          OTLP/HTTP endpoint the metrics pipeline exports to. `null` disables
          the pipeline entirely.
        '';
      };

      logs = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        example = "http://selfcloud.lan:9428/insert/opentelemetry/v1/logs";
        description = ''
          OTLP/HTTP endpoint the logs pipeline exports to. `null` disables the
          pipeline entirely.
        '';
      };

      traces = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        example = "http://selfcloud.lan:10428/insert/opentelemetry/v1/traces";
        description = ''
          OTLP/HTTP endpoint the traces pipeline exports to. `null` disables
          the pipeline entirely.
        '';
      };
    };

    listenAddress = lib.mkOption {
      type = lib.types.str;
      default = "127.0.0.1";
      description = ''
        Address the OTLP receivers bind to. The gateway is meant for
        co-located applications; combine a public address with
        {option}`openFirewall` to accept telemetry from other machines.
      '';
    };

    grpcPort = lib.mkOption {
      type = lib.types.port;
      default = 4317;
      description = "OTLP/gRPC listen port.";
    };

    httpPort = lib.mkOption {
      type = lib.types.port;
      default = 4318;
      description = "OTLP/HTTP listen port.";
    };

    openFirewall = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Open the OTLP gRPC and HTTP ports in the firewall.";
    };

    memoryLimitMiB = lib.mkOption {
      type = lib.types.ints.positive;
      default = 256;
      description = "Hard memory limit enforced by the memory_limiter processor.";
    };

    extraSettings = lib.mkOption {
      inherit (pkgs.formats.yaml { }) type;
      default = { };
      description = ''
        Deep-merged into {option}`services.opentelemetry-collector.settings`,
        for components the module does not model (e.g. the debug exporter).
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = activeSignals != { };
        message = ''
          modules.services.otelcol: at least one of
          endpoints.{metrics,logs,traces} must be set, otherwise the gateway
          would silently drop everything it receives.
        '';
      }
    ];

    services.opentelemetry-collector = {
      enable = true;
      inherit (cfg) package;
      inherit settings;
    };

    networking.firewall.allowedTCPPorts = lib.mkIf cfg.openFirewall [
      cfg.grpcPort
      cfg.httpPort
    ];
  };
}
