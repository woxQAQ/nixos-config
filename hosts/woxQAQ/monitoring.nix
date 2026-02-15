{
  ...
}:
{
  imports = [
    ./grafana
    ./victoriametrics
  ];
  # Open firewall for all monitoring services
  networking.firewall.allowedTCPPorts = [
    3000 # Grafana
    8428 # VictoriaMetrics (also OpenTelemetry metrics endpoint)
    8429 # vmagent HTTP endpoint
    9100 # node_exporter
    9428 # victorialogs (OpenTelemetry logs endpoint)
  ];
}
