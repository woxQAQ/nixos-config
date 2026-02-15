{ pkgs, ... }:
{

  environment.etc."grafana/dashboards".source = ./dashboards;
  services.grafana = {
    enable = true;
    dataDir = "/data/apps/grafana";
    settings = {
      server = {
        http_port = 3000;
        root_url = "http://localhost:3000";
        enforce_domain = false;
        read_timeout = "180s";
        enable_gzip = true;
      };
      security = {
        admin_user = "admin";
        # IMPORTANT: Change this after first login!
        # TODO: consider put password into secret repos
        admin_password = "admin";
      };
      users = {
        allow_sign_up = false;
      };
    };
    declarativePlugins = with pkgs.grafanaPlugins; [
      victoriametrics-metrics-datasource
      victoriametrics-logs-datasource

      grafana-github-datasource
      # https://github.com/grafana/grafana-infinity-datasource
      # Visualize data from JSON, CSV, XML, GraphQL and HTML endpoints in Grafana
      yesoreyeram-infinity-datasource
    ];
    provision = {
      enable = true;
      dashboards.settings = {
        apiVersion = 1;

        providers = [
          {
            # <string> an unique provider name. Required
            name = "woxQAQ";
            # An organization is an entity that helps you isolate users and resources such as dashboards,
            # annotations, and data sources from each other.
            #
            # <int> Org id. Default to 1
            #
            # If you want to customize this id, you need to create the organizations first.
            orgId = 1;
            # <string> provider type. Default to 'file'
            type = "file";
            # <bool> disable dashboard deletion
            disableDeletion = true;
            # <int> how often Grafana will scan for changed dashboards
            updateIntervalSeconds = 20;
            # <bool> allow updating provisioned dashboards from the UI
            allowUiUpdates = false;
            options = {
              # <string, required> path to dashboard files on disk. Required when using the 'file' type
              path = "/etc/grafana/dashboards/";
              # <bool> use folder names from filesystem to create folders in Grafana
              foldersFromFilesStructure = true;
            };
          }
        ];
      };
      datasources.settings = {
        apiVersion = 1;
        prune = true;
        datasources = [
          {
            name = "Prometheus";
            type = "prometheus";
            url = "http://localhost:8428";
          }
          {
            name = "infinity-dataviewer";
            type = "yesoreyeram-infinity-datasource";
            editable = false;
          }
          {
            name = "victoriametrics";
            type = "victoriametrics-metrics-datasource";
            url = "http://localhost:8428";
            # url: http://vmselect:8481/select/0/prometheus  # cluster version
            isDefault = true;
            editable = false;
          }
          {
            name = "victorialogs";
            type = "victoriametrics-logs-datasource";
            url = "http://localhost:9428";
            editable = false;
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

  };
}
