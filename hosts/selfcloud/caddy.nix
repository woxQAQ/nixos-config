{ config, ... }:
let
  monitoringPorts = config.modules.services.monitoring.ports;
in
{
  services.caddy = {
    enable = true;
    # LAN certificates are issued and renewed by Caddy's internal CA.
    # Caddy preserves Host, sets X-Forwarded-* and handles WebSocket upgrades.
    globalConfig = ''
      local_certs
      skip_install_trust
    '';
    virtualHosts = {
      "sftp.selfcloud.lan".extraConfig = ''
        reverse_proxy 127.0.0.1:8081
      '';

      "gitea.selfcloud.lan".extraConfig = ''
        reverse_proxy 127.0.0.1:${toString config.services.gitea.settings.server.HTTP_PORT}
      '';

      "jellyfin.selfcloud.lan".extraConfig = ''
        reverse_proxy 127.0.0.1:8096
      '';

      "qbittorrent.selfcloud.lan".extraConfig = ''
        # Keep Host, Origin and Referer consistent for qBittorrent's CSRF checks.
        reverse_proxy 127.0.0.1:8080
      '';

      "grafana.selfcloud.lan".extraConfig = ''
        reverse_proxy 127.0.0.1:${toString config.services.grafana.settings.server.http_port}
      '';

      "victoriametrics.selfcloud.lan".extraConfig = ''
        redir / /vmui/ 302
        reverse_proxy 127.0.0.1:${toString monitoringPorts.metrics}
      '';

      "victorialogs.selfcloud.lan".extraConfig = ''
        redir / /select/vmui/ 302
        reverse_proxy 127.0.0.1:${toString monitoringPorts.logs}
      '';

      "victoriatraces.selfcloud.lan".extraConfig = ''
        reverse_proxy 127.0.0.1:${toString monitoringPorts.traces}
      '';
    };
  };

  networking.firewall = {
    allowedTCPPorts = [
      80
      443
    ];
    allowedUDPPorts = [ 443 ]; # HTTP/3
  };
}
