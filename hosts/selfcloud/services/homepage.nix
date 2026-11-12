{ config, lib, ... }:
let
  monitoringPorts = config.modules.services.monitoring.ports;
  grafana = "https://grafana.selfcloud.lan";
  grafanaHealth = "http://127.0.0.1:${toString config.services.grafana.settings.server.http_port}/api/health";
  tracesExplore = "${grafana}/explore?schemaVersion=1&panes=${
    lib.escapeURL (
      builtins.toJSON {
        traces = {
          datasource = "victoriatraces";
          queries = [ ];
          range = {
            from = "now-1h";
            to = "now";
          };
        };
      }
    )
  }";
in
{
  services.homepage-dashboard = {
    enable = true;
    listenPort = 8082;
    allowedHosts = "selfcloud.lan,localhost:8082,127.0.0.1:8082";
    settings = {
      title = "Selfcloud";
      description = "家庭服务与主机监控";
      language = "zh-Hans";
      theme = "dark";
      color = "slate";
      headerStyle = "clean";
      statusStyle = "dot";
      hideVersion = true;
      disableCollapse = true;
      target = "_self";
      layout = [
        {
          "服务" = {
            style = "row";
            columns = 4;
          };
        }
        {
          "监控" = {
            style = "row";
            columns = 3;
          };
        }
        {
          "诊断" = {
            style = "row";
            columns = 3;
          };
        }
      ];
    };
    widgets = [
      {
        resources = {
          label = "Selfcloud";
          cpu = true;
          memory = true;
          uptime = true;
        };
      }
      {
        datetime = {
          locale = "zh-CN";
          format = {
            dateStyle = "medium";
            timeStyle = "short";
            hourCycle = "h23";
          };
        };
      }
    ];
    services = [
      {
        "服务" = [
          {
            SFTPGo = {
              href = "https://sftp.selfcloud.lan/";
              description = "文件浏览与上传";
              siteMonitor = "http://127.0.0.1:8081/";
            };
          }
          {
            Jellyfin = {
              href = "https://jellyfin.selfcloud.lan/";
              description = "媒体库与播放";
              siteMonitor = "http://127.0.0.1:8096/health";
            };
          }
          {
            qBittorrent = {
              href = "https://qbittorrent.selfcloud.lan/";
              description = "下载任务";
              siteMonitor = "http://127.0.0.1:8080/";
            };
          }
          {
            Gitea = {
              href = "https://gitea.selfcloud.lan/";
              description = "代码仓库";
              siteMonitor = "http://127.0.0.1:${toString config.services.gitea.settings.server.HTTP_PORT}/";
            };
          }
        ];
      }
      {
        "监控" = [
          {
            Grafana = {
              href = "${grafana}/";
              description = "仪表盘与告警";
              siteMonitor = grafanaHealth;
            };
          }
          {
            "主机指标" = {
              href = "${grafana}/d/selfcloud-node-exporter/node-exporter";
              description = "CPU、内存、磁盘与网络";
              siteMonitor = grafanaHealth;
            };
          }
          {
            "存储状态" = {
              href = "${grafana}/d/selfcloud-storage/selfcloud-storage";
              description = "RAID、SMART 与数据盘容量";
              siteMonitor = grafanaHealth;
            };
          }
        ];
      }
      {
        "诊断" = [
          {
            VictoriaMetrics = {
              href = "https://victoriametrics.selfcloud.lan/vmui/";
              description = "指标查询";
              siteMonitor = "http://127.0.0.1:${toString monitoringPorts.metrics}/health";
            };
          }
          {
            VictoriaLogs = {
              href = "https://victorialogs.selfcloud.lan/select/vmui/";
              description = "日志查询";
              siteMonitor = "http://127.0.0.1:${toString monitoringPorts.logs}/health";
            };
          }
          {
            VictoriaTraces = {
              href = tracesExplore;
              description = "在 Grafana Explore 中查询链路";
              siteMonitor = "http://127.0.0.1:${toString monitoringPorts.traces}/health";
            };
          }
        ];
      }
    ];
  };

  systemd.services.homepage-dashboard.environment.HOSTNAME = "127.0.0.1";
}
