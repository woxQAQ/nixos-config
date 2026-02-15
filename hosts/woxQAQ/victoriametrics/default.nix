_: {
  # Enable node_exporter for system metrics
  services = {
    prometheus.exporters.node = {
      enable = true;
      enabledCollectors = [
        "systemd"
        "processes"
      ];
    };

    victoriametrics = {
      enable = true;
      listenAddress = "127.0.0.1:8428";
      retentionPeriod = "30d";

      extraOptions = [
        # Allowed percent of system memory VictoriaMetrics caches may occupy.
        "-memory.allowedPercent=50"
      ];
      # Directory below /var/lib to store victoriametrics metrics data.
      stateDir = "victoriametrics";
      # Note: vmagent handles all scraping, so we don't use prometheusConfig here
      # to avoid duplicate metrics collection
    };

    # vmagent - Victoria Metrics agent for scraping metrics from exporters
    vmagent = {
      enable = true;
      remoteWrite.url = "http://127.0.0.1:8428/api/v1/write";
      extraArgs = [
        # Set custom port for HTTP metrics endpoint (default is 8429)
        "-httpListenAddr=:8429"
      ];
      prometheusConfig = {
        # global = {
        #   scrape_interval = "30s";
        #   external_labels = {
        #     datacenter = "homelab";
        #   };
        # };
        scrape_configs = [
          {
            job_name = "node-exporter";
            static_configs = [
              {
                targets = [ "localhost:9100" ];
                labels = {
                  host = "woxQAQ";
                };
              }
            ];
          }
        ];
      };
    };

    # victorialogs - Victoria Logs for log storage with OpenTelemetry support
    # OpenTelemetry logs endpoint: http://localhost:9428/insert/opentelemetry/v1/logs
    victorialogs = {
      enable = true;
      listenAddress = ":9428";
    };
  };

  users.groups.victoriametrics-data = { };
  users.groups.victoriametrics-logs = { };

  # Workaround for victoriametrics to store data in another place
  # https://www.freedesktop.org/software/systemd/man/latest/tmpfiles.d.html#Type
  # Symlinks do not work with DynamicUser, so we should use bind mount here.
  # https://github.com/systemd/systemd/issues/25097#issuecomment-1929074961
  systemd = {
    tmpfiles.rules = [
      "d /data/apps/victoriametrics 0770 root victoriametrics-data - -"
      "d /data/apps/victorialogs 0770 root victoriametrics-logs - -"
    ];

    services = {
      victoriametrics.serviceConfig = {
        SupplementaryGroups = [ "victoriametrics-data" ];
        BindPaths = [ "/data/apps/victoriametrics:/var/lib/victoriametrics:rbind" ];
      };

      victorialogs.serviceConfig = {
        SupplementaryGroups = [ "victoriametrics-logs" ];
        BindPaths = [ "/data/apps/victorialogs:/var/lib/victorialogs:rbind" ];
      };
    };
  };
}
