{
  # Client side of the monitoring setup: the hub (VictoriaMetrics family and
  # Grafana) runs on selfcloud. This host only exposes node_exporter for
  # vmagent to scrape, and runs the OTLP gateway that forwards application
  # telemetry to the hub.
  imports = [ ../../modules/x86_64-linux/services ];

  # Scraped by selfcloud over the LAN; the firewall already trusts
  # 192.168.31.0/24, so no extra port opening is needed here.
  services.prometheus.exporters.node = {
    enable = true;
    enabledCollectors = [
      "systemd"
      "processes"
    ];
  };

  modules.services.otelcol = {
    enable = true;
    endpoints = {
      # `.lan` names come from the router's DNS. On this host clash-verge's
      # TUN mode intercepts them (fake-ip), which works today but depends on
      # the clash ruleset treating LAN traffic as DIRECT.
      metrics = "http://selfcloud.lan:8428/opentelemetry/v1/metrics";
      logs = "http://selfcloud.lan:9428/insert/opentelemetry/v1/logs";
      traces = "http://selfcloud.lan:10428/insert/opentelemetry/v1/traces";
    };
  };
}
