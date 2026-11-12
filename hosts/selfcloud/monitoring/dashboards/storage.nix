{ lib }:
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
  panel = id: title: type: unit: expression: {
    inherit
      id
      title
      type
      datasource
      ;
    gridPos = {
      x = if lib.mod (id - 1) 2 == 0 then 0 else 12;
      y = builtins.div (id - 1) 2 * 8;
      w = 12;
      h = 8;
    };
    fieldConfig.defaults = {
      inherit unit;
    }
    // lib.optionalAttrs (unit == "percentunit") {
      min = 0;
      max = 1;
      thresholds = {
        mode = "absolute";
        steps = [
          {
            color = "green";
            value = null;
          }
          {
            color = "orange";
            value = 0.85;
          }
          {
            color = "red";
            value = 0.95;
          }
        ];
      };
    };
    options = lib.optionalAttrs (type == "stat") { colorMode = "none"; };
    targets = [
      {
        refId = "A";
        expr = expression;
        legendFormat = "__auto";
      }
    ];
  };
in
{
  uid = "selfcloud-storage";
  title = "Selfcloud storage";
  schemaVersion = 39;
  version = 1;
  tags = [
    "selfcloud"
    "storage"
  ];
  timezone = "browser";
  refresh = "1m";
  time = {
    from = "now-24h";
    to = "now";
  };
  panels = [
    (panel 1 "RAID degraded disks (0 = healthy)" "stat" "short"
      ''max(node_md_degraded{${node},device="md0"})''
    )
    (panel 2 "Data filesystem used" "gauge" "percentunit"
      "1 - node_filesystem_avail_bytes{${filesystem}} / node_filesystem_size_bytes{${filesystem}}"
    )
    (panel 3 "Disk temperature" "timeseries" "celsius"
      ''smartctl_device_temperature{${smart},temperature_type="current"}''
    )
    (panel 4 "SMART health (1 = passed)" "timeseries" "short"
      "smartctl_device_smart_status{${smart}}"
    )
    (panel 5 "Reallocated, pending and uncorrectable sectors" "timeseries" "short"
      ''${attributes},attribute_id=~"5|187|197|198"}''
    )
    (panel 6 "Head load and spindle start/stop counts" "timeseries" "short"
      ''${attributes},attribute_id=~"4|193"}''
    )
    (panel 7 "Failed storage maintenance units (0 = healthy)" "stat" "short"
      "max(node_systemd_unit_state{${maintenance}}) or vector(0)"
    )
    (panel 8 "SMART exporter available (1 = healthy)" "stat" "short"
      "max(up{${smart}}) or vector(0)"
    )
  ];
}
