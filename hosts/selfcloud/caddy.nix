{ config, ... }:
let
  monitoringPorts = config.modules.services.monitoring.ports;
in
{
  services.caddy = {
    enable = true;
    # LAN names use HTTP without requiring clients to trust a private CA.
    # Caddy preserves Host, sets X-Forwarded-* and handles WebSocket upgrades.
    virtualHosts = {
      "http://sftp.selfcloud.lan".extraConfig = ''
        reverse_proxy 127.0.0.1:8081
      '';

      "http://gitea.selfcloud.lan".extraConfig = ''
        reverse_proxy 127.0.0.1:${toString config.services.gitea.settings.server.HTTP_PORT}
      '';

      "http://jellyfin.selfcloud.lan".extraConfig = ''
        reverse_proxy 127.0.0.1:8096
      '';

      "http://qbittorrent.selfcloud.lan".extraConfig = ''
        # Keep Host, Origin and Referer consistent for qBittorrent's CSRF checks.
        reverse_proxy 127.0.0.1:8080
      '';

      "http://grafana.selfcloud.lan".extraConfig = ''
        reverse_proxy 127.0.0.1:${toString config.services.grafana.settings.server.http_port}
      '';

      "http://victoriametrics.selfcloud.lan".extraConfig = ''
        redir / /vmui/ 302
        reverse_proxy 127.0.0.1:${toString monitoringPorts.metrics}
      '';

      "http://victorialogs.selfcloud.lan".extraConfig = ''
        redir / /select/vmui/ 302
        reverse_proxy 127.0.0.1:${toString monitoringPorts.logs}
      '';

      "http://victoriatraces.selfcloud.lan".extraConfig = ''
        reverse_proxy 127.0.0.1:${toString monitoringPorts.traces}
      '';
    };
  };

  networking.firewall.allowedTCPPorts = [ 80 ];
}
