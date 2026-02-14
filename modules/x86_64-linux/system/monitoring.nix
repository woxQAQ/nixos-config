{
  config,
  lib,
  ...
}:
let
  cfg = config.modules.system.monitoring;
in
{
  options.modules.system.monitoring = {
    enable = lib.mkEnableOption "Enable system monitoring with Prometheus and Grafana";
    grafanaAdminPasswordFile = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
      description = "Path to file containing Grafana admin password (for agenix secrets)";
    };
  };

  config = lib.mkIf cfg.enable {
    services.prometheus = {
      enable = true;
      port = 9090;
      globalConfig = {
        scrape_interval = "15s";
        evaluation_interval = "15s";
      };
      scrapeConfigs = [
        {
          job_name = "node";
          static_configs = [
            {
              targets = [ "127.0.0.1:${toString config.services.prometheus.exporters.node.port}" ];
            }
          ];
        }
      ];
      exporters = {
        node = {
          enable = true;
          enabledCollectors = [
            "systemd"
            "processes"
            "filesystem"
            "hwmon"
            "netdev"
            "stat"
          ];
          port = 9100;
        };
      };
    };

    services.grafana = {
      enable = true;
      settings = {
        server = {
          http_port = 3000;
          root_url = "http://localhost:3000";
        };
        security = {
          admin_user = "admin";
          # IMPORTANT: Change this after first login!
          # Uses password file if provided via grafanaAdminPasswordFile option
          admin_password =
            if cfg.grafanaAdminPasswordFile != null then cfg.grafanaAdminPasswordFile else "admin";
        };
      };
      provision = {
        datasources.settings.datasources = [
          {
            name = "Prometheus";
            type = "prometheus";
            url = "http://localhost:9090";
            isDefault = true;
          }
        ];
        # Note: Dashboard packages may not be available in all nixpkgs versions
        # Dashboards can be imported manually through the Grafana UI
        # dashboards.settings.providers = [
        #   {
        #     name = "Node Exporter";
        #     options.path = pkgs.grafana-dashboards-node-exporter;
        #   }
        #   {
        #     name = "Prometheus";
        #     options.path = pkgs.grafana-dashboards-prometheus;
        #   }
        # ];
      };
    };

    # Open firewall for all monitoring services
    networking.firewall.allowedTCPPorts = [
      3000
      9090
      9100
    ];
  };
}
