{
  config,
  pkgs,
  ...
}:
let
  datasource = {
    type = "prometheus";
    uid = "selfcloud-storage";
  };
  node = ''host="selfcloud",job="node-exporter"'';
  smart = ''host="selfcloud",job="smartctl"'';
  filesystem = ''${node},mountpoint="/mnt/data"'';
  attributes = ''smartctl_device_attribute{${smart},attribute_value_type="raw"'';
  maintenance = ''${node},state="failed",name=~"storage-.*[.]service|btrfs-scrub@.*[.]service|smartd[.]service|mdmonitor[.]service"'';
  diskCount = builtins.length config.services.smartd.devices;

  # Instant queries return numeric series; the expression turns each series
  # into a separate alert instance while preserving its disk labels.
  alert = uid: title: severity: duration: expression: description: {
    uid = "storage-${uid}";
    inherit title;
    condition = "B";
    for = duration;
    noDataState = "Alerting";
    execErrState = "Alerting";
    labels = {
      host = "selfcloud";
      component = "storage";
      inherit severity;
    };
    annotations = {
      summary = title;
      inherit description;
      __dashboardUid__ = "selfcloud-storage";
      __panelId__ = "1";
    };
    data = [
      {
        refId = "A";
        datasourceUid = datasource.uid;
        relativeTimeRange = {
          from = 600;
          to = 0;
        };
        model = {
          inherit datasource;
          refId = "A";
          expr = expression;
          instant = true;
          range = false;
          intervalMs = 60000;
          maxDataPoints = 43200;
        };
      }
      {
        refId = "B";
        datasourceUid = "__expr__";
        relativeTimeRange = {
          from = 0;
          to = 0;
        };
        model = {
          datasource = {
            type = "__expr__";
            uid = "__expr__";
          };
          refId = "B";
          type = "math";
          expression = "$A > 0";
        };
      }
    ];
  };

  spaceUsed = "1 - node_filesystem_avail_bytes{${filesystem}} / node_filesystem_size_bytes{${filesystem}}";
  failedUnits = "max(node_systemd_unit_state{${maintenance}}) or vector(0)";
in
{
  services.prometheus.exporters.smartctl = {
    enable = true;
    listenAddress = "127.0.0.1";
    devices = map (disk: disk.device) config.services.smartd.devices;
    maxInterval = "5m";
  };
  services.vmagent.prometheusConfig.scrape_configs = [
    {
      job_name = "smartctl";
      scrape_interval = "1m";
      scrape_timeout = "30s";
      static_configs = [
        {
          targets = [
            "127.0.0.1:${toString config.services.prometheus.exporters.smartctl.port}"
          ];
          labels.host = "selfcloud";
        }
      ];
    }
  ];

  # Grafana 13 packages the Prometheus datasource as a separate plugin.
  services.grafana.declarativePlugins = [ pkgs.grafanaPlugins.prometheus ];
  services.grafana.provision = {
    # A stable UID keeps the host dashboard and rules independent of the
    # automatically assigned UIDs of the existing interactive datasources.
    datasources.settings.datasources = [
      {
        name = "Selfcloud storage";
        inherit (datasource) type uid;
        access = "proxy";
        url = "http://127.0.0.1:${toString config.modules.services.monitoring.ports.metrics}";
        editable = false;
      }
    ];
    alerting.rules.settings.groups = [
      {
        orgId = 1;
        name = "selfcloud-storage";
        folder = "Selfcloud";
        interval = "1m";
        rules = [
          (alert "node-unavailable" "Storage node metrics unavailable" "critical" "5m"
            "1 - (max(up{${node}}) or vector(0))"
            "The node exporter cannot be scraped; RAID and mount status cannot be evaluated."
          )
          (alert "smart-unavailable" "SMART exporter unavailable" "critical" "5m"
            "1 - (max(up{${smart}}) or vector(0))"
            "The SMART exporter cannot be scraped."
          )
          (alert "smart-missing" "Expected disk SMART metrics missing" "critical" "10m"
            "${toString diskCount} - (count(smartctl_device_smart_status{${smart}}) or vector(0))"
            "At least one configured disk has no SMART health metric; inspect device availability and exporter logs."
          )
          (alert "raid-degraded" "RAID unavailable or degraded" "critical" "2m"
            ''max(node_md_degraded{${node},device="md0"}) or vector(1)''
            "md0 is missing or has fewer active members than required."
          )
          (alert "mount-missing" "Data filesystem not mounted" "critical" "2m"
            "1 - (max(node_filesystem_mount_info{${filesystem}}) or vector(0))"
            "The expected /mnt/data mount is absent."
          )
          (alert "readonly" "Data filesystem is read-only" "critical" "2m"
            "max(node_filesystem_readonly{${filesystem}}) or vector(0)"
            "Btrfs may have remounted read-only after an error; inspect kernel logs."
          )
          (alert "space-warning" "Data filesystem over 85% used" "warning" "15m"
            "(${spaceUsed}) > bool 0.85"
            "Free space is below 15%; plan cleanup or expansion."
          )
          (alert "space-critical" "Data filesystem over 95% used" "critical" "5m"
            "(${spaceUsed}) > bool 0.95"
            "Free space is below 5%; reduce writes and recover free space."
          )
          (alert "smart-failed" "Disk SMART health failed" "critical" "5m"
            "1 - smartctl_device_smart_status{${smart}}"
            "A disk reports SMART health failure; inspect its detailed SMART report."
          )
          (alert "sectors-warning"
            "Disk has reallocated or reported uncorrectable sectors"
            "warning"
            "10m"
            ''${attributes},attribute_id=~"5|187"}''
            "A disk has historical media defects. Track the count and plan replacement; this does not imply a new error."
          )
          (alert "sectors-critical" "Disk has pending or offline uncorrectable sectors"
            "critical"
            "5m"
            ''${attributes},attribute_id=~"197|198"}''
            "A disk has unresolved sector errors; verify backups and inspect the disk."
          )
          (alert "temperature" "Disk temperature above 50 C" "warning" "15m"
            ''smartctl_device_temperature{${smart},temperature_type="current"} > bool 50''
            "Check airflow and sustained I/O load."
          )
          (alert "monitors-stopped" "SMART or RAID monitor not running" "critical" "5m"
            ''2 - (sum(node_systemd_unit_state{${node},state="active",name=~"smartd[.]service|mdmonitor[.]service"}) or vector(0))''
            "Both smartd and mdmonitor must remain active; inspect their service state and journal."
          )
          (alert "maintenance-failed" "Storage maintenance service failed" "critical" "2m"
            failedUnits
            "A storage check, scrub, SMART monitor, MD monitor or initialization unit failed; inspect systemctl --failed and its journal."
          )
        ];
      }
    ];
  };
}
