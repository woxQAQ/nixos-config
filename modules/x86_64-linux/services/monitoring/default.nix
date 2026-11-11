{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.modules.services.monitoring;

  inherit (cfg) ports;

  stateDirOf = service: config.services.${service}.stateDir;

  # The VictoriaMetrics family runs with DynamicUser plus a private
  # StateDirectory, and symlinks do not work under DynamicUser
  # (https://github.com/systemd/systemd/issues/25097). Relocated storage is
  # therefore bind-mounted back onto each service's StateDirectory.
  stateServices = [
    {
      name = "victoriametrics";
      group = "victoriametrics-data";
    }
    {
      name = "victorialogs";
      group = "victoriametrics-logs";
    }
    {
      name = "victoriatraces";
      group = "victoriametrics-traces";
    }
  ];

  grafanaDataDir = config.services.grafana.dataDir;
  grafanaSecretKeyFile = "${grafanaDataDir}/secret_key";
in
{
  options.modules.services.monitoring = {
    enable = lib.mkEnableOption ''
      VictoriaMetrics-based monitoring hub: VictoriaMetrics, VictoriaLogs,
      VictoriaTraces, vmagent and Grafana, wired together on one machine.

      Grafana is the panel because it is the only mature UI for the Jaeger
      query API that VictoriaTraces exposes. Metrics and logs can also be
      explored without it through VMUI at /vmui on the metrics port and the
      built-in VictoriaLogs UI at /select/vmui on the logs port.
    '';

    listenAddress = lib.mkOption {
      type = lib.types.str;
      default = "0.0.0.0";
      description = ''
        Bind address for the VictoriaMetrics family endpoints. These serve
        both Grafana queries and OTLP ingestion from remote collectors, so a
        hub usually wants a public address together with
        {option}`openFirewall`.
      '';
    };

    ports = {
      grafana = lib.mkOption {
        type = lib.types.port;
        default = 3000;
        description = "Grafana web port.";
      };
      metrics = lib.mkOption {
        type = lib.types.port;
        default = 8428;
        description = "VictoriaMetrics port: metrics storage, PromQL queries and OTLP metrics ingestion.";
      };
      logs = lib.mkOption {
        type = lib.types.port;
        default = 9428;
        description = "VictoriaLogs port: log storage, queries and OTLP logs ingestion.";
      };
      traces = lib.mkOption {
        type = lib.types.port;
        default = 10428;
        description = "VictoriaTraces port: trace storage, Jaeger queries and OTLP traces ingestion.";
      };
    };

    retentionPeriod = lib.mkOption {
      type = lib.types.str;
      default = "30d";
      description = "How long metrics, logs and traces are kept.";
    };

    dataDir = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      example = "/data/apps";
      description = ''
        Root directory for hub storage. `null` keeps the upstream state
        directories under {file}`/var/lib`. When set, the VictoriaMetrics
        family stores in {file}`<dataDir>/<service>` (bind-mounted onto the
        StateDirectory, see above) and Grafana in {file}`<dataDir>/grafana`.
      '';
    };

    openFirewall = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = ''
        Open the Grafana and VictoriaMetrics family ports in the firewall.
        vmagent's own HTTP endpoint stays loopback-only.
      '';
    };

    scrapeTargets = lib.mkOption {
      type = lib.types.listOf (
        lib.types.submodule {
          options = {
            name = lib.mkOption {
              type = lib.types.str;
              example = "selfcloud";
              description = "Value of the `host` label attached to scraped series.";
            };
            address = lib.mkOption {
              type = lib.types.str;
              example = "woxQAQ.lan:9100";
              description = "node_exporter address scraped by vmagent.";
            };
          };
        }
      );
      default = [ ];
      description = "node_exporter targets scraped by vmagent.";
    };
  };

  config = lib.mkIf cfg.enable (
    lib.mkMerge [
      {
        services.victoriametrics = {
          enable = true;
          listenAddress = lib.mkDefault "${cfg.listenAddress}:${toString ports.metrics}";
          retentionPeriod = lib.mkDefault cfg.retentionPeriod;
        };

        services.victorialogs = {
          enable = true;
          listenAddress = lib.mkDefault "${cfg.listenAddress}:${toString ports.logs}";
          extraOptions = lib.mkDefault [ "-retentionPeriod=${cfg.retentionPeriod}" ];
        };

        services.victoriatraces = {
          enable = true;
          listenAddress = lib.mkDefault "${cfg.listenAddress}:${toString ports.traces}";
          retentionPeriod = lib.mkDefault cfg.retentionPeriod;
        };

        # vmagent scrapes node_exporter targets and remote-writes into the
        # local VictoriaMetrics; its HTTP endpoint stays on loopback.
        services.vmagent = {
          enable = true;
          remoteWrite.url = lib.mkDefault "http://127.0.0.1:${toString ports.metrics}/api/v1/write";
          extraArgs = lib.mkDefault [ "-httpListenAddr=127.0.0.1:8429" ];
          prometheusConfig = lib.mkIf (cfg.scrapeTargets != [ ]) {
            scrape_configs = [
              {
                job_name = "node-exporter";
                static_configs = map (target: {
                  targets = [ target.address ];
                  labels.host = target.name;
                }) cfg.scrapeTargets;
              }
            ];
          };
        };

        # Grafana refuses $__file{...} secrets from world-readable locations, so
        # we generate the secret key next to its database on first activation.
        system.activationScripts.grafana-secret-key.text = ''
          install -d -m 0750 -o grafana -g grafana ${lib.escapeShellArg grafanaDataDir}
          if [ ! -s ${lib.escapeShellArg grafanaSecretKeyFile} ]; then
            umask 0077
            ${pkgs.openssl}/bin/openssl rand -hex 32 > ${lib.escapeShellArg grafanaSecretKeyFile}
          fi
          chown grafana:grafana ${lib.escapeShellArg grafanaSecretKeyFile}
          chmod 0400 ${lib.escapeShellArg grafanaSecretKeyFile}
        '';

        services.grafana = {
          enable = true;
          dataDir = lib.mkIf (cfg.dataDir != null) "${cfg.dataDir}/grafana";
          settings = {
            server = {
              http_port = lib.mkDefault ports.grafana;
              root_url = lib.mkDefault "http://localhost:${toString ports.grafana}";
              enforce_domain = lib.mkDefault false;
              read_timeout = lib.mkDefault "180s";
              enable_gzip = lib.mkDefault true;
            };
            security = {
              admin_user = lib.mkDefault "admin";
              # IMPORTANT: change this after first login!
              # TODO: consider putting the password into the secrets repo.
              admin_password = lib.mkDefault "admin";
              secret_key = "$__file{${grafanaSecretKeyFile}}";
            };
            users.allow_sign_up = lib.mkDefault false;
          };
          declarativePlugins = with pkgs.grafanaPlugins; [
            victoriametrics-metrics-datasource
            victoriametrics-logs-datasource

            grafana-github-datasource
            # Visualize data from JSON, CSV, XML, GraphQL and HTML endpoints.
            yesoreyeram-infinity-datasource
          ];
          # No dashboard provisioning: dashboards are managed interactively.
          # Datasources are still provisioned so the hub works out of the box.
          provision = {
            enable = true;
            datasources.settings = {
              apiVersion = 1;
              prune = true;
              datasources = [
                {
                  name = "Prometheus";
                  type = "prometheus";
                  url = "http://127.0.0.1:${toString ports.metrics}";
                }
                {
                  name = "infinity-dataviewer";
                  type = "yesoreyeram-infinity-datasource";
                  editable = false;
                }
                {
                  name = "victoriametrics";
                  type = "victoriametrics-metrics-datasource";
                  url = "http://127.0.0.1:${toString ports.metrics}";
                  isDefault = true;
                  editable = false;
                }
                {
                  name = "victorialogs";
                  type = "victoriametrics-logs-datasource";
                  url = "http://127.0.0.1:${toString ports.logs}";
                  editable = false;
                }
                {
                  # VictoriaTraces exposes a Jaeger-compatible query API.
                  name = "victoriatraces";
                  type = "jaeger";
                  uid = "victoriatraces";
                  url = "http://127.0.0.1:${toString ports.traces}/select/jaeger";
                  editable = false;
                }
              ];
            };
          };
        };

        networking.firewall.allowedTCPPorts = lib.mkIf cfg.openFirewall [
          ports.grafana
          ports.metrics
          ports.logs
          ports.traces
        ];
      }

      (lib.mkIf (cfg.dataDir != null) {
        users.groups = lib.listToAttrs (
          map (service: lib.nameValuePair service.group { }) stateServices
        );

        systemd.tmpfiles.rules = map (
          service: "d ${cfg.dataDir}/${service.name} 0770 root ${service.group} - -"
        ) stateServices;

        systemd.services = lib.listToAttrs (
          map (service: {
            inherit (service) name;
            value.serviceConfig = {
              SupplementaryGroups = [ service.group ];
              BindPaths = [
                "${cfg.dataDir}/${service.name}:/var/lib/${stateDirOf service.name}:rbind"
              ];
            };
          }) stateServices
        );
      })
    ]
  );
}
