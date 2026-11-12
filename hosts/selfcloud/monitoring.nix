{
  # Monitoring hub for the home network: metrics, logs and traces are stored
  # here and explored through the built-in VMUI / VictoriaLogs UI. woxQAQ
  # runs the node_exporter being scraped below and an OTLP gateway pushing
  # into these endpoints.
  imports = [ ../../modules/x86_64-linux/services ];

  modules.services.monitoring = {
    enable = true;
    openFirewall = true;
    ports.grafana = 3001;
    scrapeTargets = [
      {
        name = "selfcloud";
        address = "localhost:9100";
      }
      {
        # `.lan` names are resolved by the router's DNS (192.168.31.1).
        name = "woxQAQ";
        address = "woxQAQ.lan:9100";
      }
    ];
  };
}
