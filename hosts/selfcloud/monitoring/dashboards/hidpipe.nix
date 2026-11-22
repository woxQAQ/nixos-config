{ lib }:
let
  inherit (import ./lib.nix { inherit lib; }) mkDashboard mkPanel grid;
  datasource = {
    type = "tempo";
    uid = "victoriatraces-metrics";
  };
  logsDatasource = {
    type = "victoriametrics-logs-datasource";
    uid = "\${logsDatasource}";
  };
  server = ''resource.service.name = "hidpipe-server"'';
  client = ''resource.service.name = "hidpipe-client"'';
  forward = ''${server} && name = "server.forward"'';
  process = ''${client} && name = "client.process"'';
  sampledFrames = "{ (${forward}) || (${process}) }";
  target = query: {
    inherit datasource query;
    refId = "A";
    queryType = "traceql";
    filters = [ ];
  };
  timeSeries =
    id: title: description: gridPos: unit: query:
    mkPanel {
      inherit
        id
        title
        description
        gridPos
        datasource
        unit
        ;
      type = "timeseries";
      fieldConfig.defaults = {
        min = 0;
        custom.spanNulls = false;
      };
      options.tooltip.mode = "multi";
      targets = [
        (
          (target query)
          // {
            metricsQueryType = "range";
            exemplars = 0;
          }
        )
      ];
      # VictoriaTraces also returns exemplar frames alongside the bucket values.
      transformations = [
        {
          id = "filterFrames";
          options.exclude = {
            id = "byName";
            options = "exemplar";
          };
        }
      ];
    };
in
mkDashboard {
  uid = "selfcloud-hidpipe";
  title = "Hidpipe 输入追踪";
  tags = [
    "hidpipe"
    "traces"
  ];
  time = {
    from = "now-1h";
    to = "now";
  };
  templating.list = [
    {
      name = "logsDatasource";
      type = "datasource";
      query = logsDatasource.type;
      regex = "/^victorialogs$/";
      refresh = 1;
      hide = 2;
    }
  ];
  panels = [
    (timeSeries 1 "两端采样帧数"
      "每个时间桶分别统计 server.forward 和 client.process。每个采样帧在两端各产生一个这样的 span，跨桶到达可能使同一桶的数量略有差异。"
      (grid 0 0 24 6)
      "short"
      "${sampledFrames} | count_over_time() by (name)"
    )
    (timeSeries 2 "Linux 转发耗时 · P95"
      "forward 从输入帧入队开始，覆盖 queue 排队和 write 写入套接字。各阶段独立计算 P95。"
      (grid 0 6 12 8)
      "s"
      "{ ${server} && name =~ `server[.](forward|queue|write)` } | quantile_over_time(duration, 0.95) by (name)"
    )
    (timeSeries 3 "macOS 处理耗时 · P95"
      "process 从完整读入帧开始。feedback、resolve 和 inject 分别记录反馈写回、OpenLogi 解析和输入注入，按实际执行的阶段统计。"
      (grid 12 6 12 8)
      "s"
      "{ ${client} && name =~ `client[.](process|feedback|resolve|inject)` } | quantile_over_time(duration, 0.95) by (name)"
    )
    {
      id = 5;
      title = "macOS 慢注入（≥ 2 ms）";
      description = "按完成时间倒序显示慢注入，包括未采样的输入。展开记录可查看会话时长、各阶段耗时，以及采样帧的 trace_id。";
      type = "logs";
      datasource = logsDatasource;
      gridPos = grid 0 14 24 8;
      options = {
        showTime = true;
        sortOrder = "Descending";
      };
      targets = [
        {
          refId = "A";
          datasource = logsDatasource;
          queryType = "range";
          expr = ''"service.name":="hidpipe-client" AND _msg:="slow-inject" | format "<input.kind> #<input_seq>   total=<total_us> µs   create=<create_us> µs   post=<post_us> µs" as _msg'';
        }
      ];
    }
    {
      id = 4;
      title = "采样输入 Trace";
      description = "每个采样帧分别列出已上报的 Linux 转发和 macOS 处理 span，按 Trace ID 对照。跨主机时间差受时钟同步精度影响。最多查询 50 条 trace。";
      type = "table";
      inherit datasource;
      gridPos = grid 0 22 24 10;
      targets = [
        (
          (target "${sampledFrames} | select(resource.service.name, name, duration)")
          // {
            tableType = "spans";
            limit = 50;
          }
        )
      ];
    }
  ];
}
