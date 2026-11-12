{ lib }:
let
  datasource = {
    type = "prometheus";
    uid = "\${datasource}";
  };
  node = ''job="node-exporter",host=~"$host"'';
  disk = ''${node},device!~"loop.*|ram.*|zram.*"'';
  network = ''${node},device!="lo"'';
  filesystem = ''${node},fstype!~"tmpfs|devtmpfs|overlay|squashfs|nsfs"'';
  panel = id: title: type: unit: expressions: {
    inherit
      id
      title
      type
      datasource
      ;
    gridPos =
      if id <= 4 then
        {
          x = (id - 1) * 6;
          y = 0;
          w = 6;
          h = 4;
        }
      else
        {
          x = lib.mod (id - 5) 2 * 12;
          y = 4 + builtins.div (id - 5) 2 * 8;
          w = 12;
          h = 8;
        };
    fieldConfig.defaults = {
      inherit unit;
    }
    // lib.optionalAttrs (unit == "percentunit") {
      min = 0;
      max = 1;
    };
    options = lib.optionalAttrs (type == "stat") { colorMode = "none"; };
    targets = lib.imap0 (index: target: {
      refId = "Q${toString index}";
      expr = target.value;
      legendFormat = target.name;
    }) (lib.mapAttrsToList lib.nameValuePair expressions);
  };
in
{
  uid = "selfcloud-node-exporter";
  title = "Node exporter";
  description = "Host metrics collected by vmagent. Select a host to inspect CPU, memory, persistent filesystems, block devices, networking and services.";
  schemaVersion = 39;
  version = 1;
  tags = [ "node-exporter" ];
  timezone = "browser";
  refresh = "1m";
  time = {
    from = "now-6h";
    to = "now";
  };
  templating.list = [
    {
      name = "datasource";
      label = "Datasource";
      type = "datasource";
      query = "prometheus";
      refresh = 1;
      current = {
        text = "Selfcloud storage";
        value = "selfcloud-storage";
      };
    }
    {
      name = "host";
      label = "Host";
      type = "query";
      inherit datasource;
      refresh = 1;
      sort = 1;
      multi = false;
      includeAll = false;
      query = {
        query = ''label_values(up{job="node-exporter"}, host)'';
        refId = "HostVariable";
      };
      current = {
        text = "selfcloud";
        value = "selfcloud";
      };
    }
  ];
  panels = [
    (panel 1 "CPU busy" "stat" "percentunit" {
      CPU = ''1 - avg(rate(node_cpu_seconds_total{${node},mode="idle"}[$__rate_interval]))'';
    })
    (panel 2 "Memory used" "stat" "percentunit" {
      Memory = "1 - node_memory_MemAvailable_bytes{${node}} / node_memory_MemTotal_bytes{${node}}";
    })
    (panel 3 "Uptime" "stat" "s" {
      Uptime = "time() - node_boot_time_seconds{${node}}";
    })
    (panel 4 "Logical CPUs" "stat" "short" {
      CPUs = ''count(node_cpu_seconds_total{${node},mode="idle"})'';
    })
    (panel 5 "System load" "timeseries" "short" {
      "1 minute" = "node_load1{${node}}";
      "5 minutes" = "node_load5{${node}}";
      "15 minutes" = "node_load15{${node}}";
    })
    (panel 6 "Memory and swap" "timeseries" "bytes" {
      Used = "node_memory_MemTotal_bytes{${node}} - node_memory_MemAvailable_bytes{${node}}";
      Available = "node_memory_MemAvailable_bytes{${node}}";
      "Swap used" =
        "node_memory_SwapTotal_bytes{${node}} - node_memory_SwapFree_bytes{${node}}";
    })
    (panel 7 "Filesystem used" "timeseries" "percentunit" {
      "{{mountpoint}}" =
        "1 - node_filesystem_avail_bytes{${filesystem}} / node_filesystem_size_bytes{${filesystem}}";
    })
    (panel 8 "Filesystem available space" "timeseries" "bytes" {
      "{{mountpoint}}" = "node_filesystem_avail_bytes{${filesystem}}";
    })
    (panel 9 "Disk read / write throughput" "timeseries" "Bps" {
      "Read {{device}}" =
        "rate(node_disk_read_bytes_total{${disk}}[$__rate_interval])";
      "Write {{device}}" =
        "rate(node_disk_written_bytes_total{${disk}}[$__rate_interval])";
    })
    (panel 10 "Average disk read / write latency" "timeseries" "s" {
      "Read {{device}}" =
        "rate(node_disk_read_time_seconds_total{${disk}}[$__rate_interval]) / (rate(node_disk_reads_completed_total{${disk}}[$__rate_interval]) > 0)";
      "Write {{device}}" =
        "rate(node_disk_write_time_seconds_total{${disk}}[$__rate_interval]) / (rate(node_disk_writes_completed_total{${disk}}[$__rate_interval]) > 0)";
    })
    (panel 11 "Disk I/O busy time" "timeseries" "percentunit" {
      "{{device}}" =
        "rate(node_disk_io_time_seconds_total{${disk}}[$__rate_interval])";
    })
    (panel 12 "Network receive / transmit throughput" "timeseries" "Bps" {
      "Receive {{device}}" =
        "rate(node_network_receive_bytes_total{${network}}[$__rate_interval])";
      "Transmit {{device}}" =
        "rate(node_network_transmit_bytes_total{${network}}[$__rate_interval])";
    })
    (panel 13 "Network receive / transmit errors" "timeseries" "ops" {
      "Receive {{device}}" =
        "rate(node_network_receive_errs_total{${network}}[$__rate_interval])";
      "Transmit {{device}}" =
        "rate(node_network_transmit_errs_total{${network}}[$__rate_interval])";
    })
    (panel 14 "Network receive / transmit drops" "timeseries" "pps" {
      "Receive {{device}}" =
        "rate(node_network_receive_drop_total{${network}}[$__rate_interval])";
      "Transmit {{device}}" =
        "rate(node_network_transmit_drop_total{${network}}[$__rate_interval])";
    })
    (panel 15 "Failed systemd units" "timeseries" "short" {
      Failed = ''sum(node_systemd_unit_state{${node},state="failed"})'';
    })
    (panel 16 "Running / blocked processes" "timeseries" "short" {
      Running = "node_procs_running{${node}}";
      Blocked = "node_procs_blocked{${node}}";
    })
  ];
}
