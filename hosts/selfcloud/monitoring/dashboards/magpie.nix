{ lib }:
let
  datasource = {
    type = "prometheus";
    uid = "selfcloud-storage";
  };
  # OTLP ingestion preserves dots in metric and label names.
  selector = ''"service.name"="magpie","scope.name"="github.com/yetone/magpie"'';
  calls = ''{"gen_ai.client.operation.duration_count",${selector}}'';
  errors = ''{"gen_ai.client.operation.duration_count",${selector},"error.type"!=""}'';
  duration = ''{"gen_ai.client.operation.duration_sum",${selector}}'';
  buckets = ''{"gen_ai.client.operation.duration_bucket",${selector}}'';
  tokens = ''{"gen_ai.client.token.usage_sum",${selector}}'';
  totalCalls = "sum(increase(${calls}[$__range]))";
  totalErrors = "(sum(increase(${errors}[$__range])) or (0 * ${totalCalls}))";
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
          y = 4 + builtins.div (id - 5) 2 * 10;
          w = 12;
          h = if type == "bargauge" then 14 else 10;
        };
    interval = "$bucket";
    fieldConfig.defaults = {
      inherit unit;
      min = if unit == "s" then 0.001 else 0;
      color = {
        mode = if type == "bargauge" then "fixed" else "palette-classic";
        fixedColor = "blue";
      };
    }
    // lib.optionalAttrs (unit == "percentunit") { max = 1; }
    // lib.optionalAttrs (unit == "short") { decimals = 0; }
    // lib.optionalAttrs (type == "timeseries") {
      custom = {
        drawStyle = if unit == "s" then "line" else "bars";
        fillOpacity = if unit == "s" then 0 else 65;
        lineWidth = 1;
        showPoints = if unit == "s" then "always" else "never";
        pointSize = 3;
        spanNulls = false;
        stacking = {
          mode = if unit == "s" then "none" else "normal";
          group = "A";
        };
        axisLabel = if unit == "s" then "耗时（对数刻度）" else "每个统计窗口的数量";
        scaleDistribution =
          if unit == "s" then
            {
              type = "log";
              log = 10;
            }
          else
            { type = "linear"; };
      };
    };
    options =
      if type == "timeseries" then
        {
          tooltip.mode = "multi";
          legend = {
            displayMode = "table";
            placement = "bottom";
            calcs = [ "max" ];
          };
        }
      else if type == "bargauge" then
        {
          orientation = "horizontal";
          displayMode = "basic";
          showUnfilled = false;
          namePlacement = "left";
          valueMode = "text";
          minVizHeight = 24;
          reduceOptions = {
            calcs = [ "lastNotNull" ];
            values = false;
          };
        }
      else
        {
          colorMode = "none";
          graphMode = "none";
          reduceOptions.calcs = [ "lastNotNull" ];
        };
    targets = lib.imap0 (index: target: {
      refId = "Q${toString index}";
      expr = target.value;
      legendFormat = target.name;
      instant = type != "timeseries";
      range = type == "timeseries";
    }) (lib.mapAttrsToList lib.nameValuePair expressions);
  };
in
{
  uid = "selfcloud-magpie";
  title = "Magpie · 模型用量";
  description = "总量与排行按右上角时间范围统计；趋势按所选统计粒度计算窗口增量。调用数遵循 Magpie 导出的 operation 口径，可能包含重试。Token 为直方图 sum，输入可能包含重复上下文，不代表新增文本。延迟采用对数刻度保留异常长请求；无调用时不显示延迟。";
  schemaVersion = 39;
  version = 2;
  tags = [
    "selfcloud"
    "magpie"
    "gen-ai"
  ];
  timezone = "browser";
  refresh = "1m";
  time = {
    from = "now-24h";
    to = "now";
  };
  templating.list = [
    {
      name = "bucket";
      label = "统计粒度";
      type = "custom";
      query = "5m,15m,1h,6h,1d";
      current = {
        text = "1h";
        value = "1h";
      };
      options =
        map
          (value: {
            text = value;
            inherit value;
            selected = value == "1h";
          })
          [
            "5m"
            "15m"
            "1h"
            "6h"
            "1d"
          ];
    }
  ];
  panels = [
    (panel 1 "调用总数" "stat" "short" { Calls = totalCalls; })
    (panel 2 "错误率" "stat" "percentunit" {
      Errors = "${totalErrors} / (${totalCalls} > 0)";
    })
    (panel 3 "输入 Token" "stat" "short" {
      Input = ''sum(increase({"gen_ai.client.token.usage_sum",${selector},"gen_ai.token.type"="input"}[$__range]))'';
    })
    (panel 4 "输出 Token" "stat" "short" {
      Output = ''sum(increase({"gen_ai.client.token.usage_sum",${selector},"gen_ai.token.type"="output"}[$__range]))'';
    })
    (panel 5 "调用次数 / $bucket · 按供应商" "timeseries" "short" {
      "{{gen_ai.provider.name}}" =
        ''sum by ("gen_ai.provider.name") (increase(${calls}[$bucket]))'';
    })
    (panel 6 "Token 用量 / $bucket" "timeseries" "short" {
      "{{gen_ai.token.type}}" =
        ''sum by ("gen_ai.token.type") (increase(${tokens}[$bucket]))'';
    })
    (
      (panel 7 "调用耗时 / $bucket" "timeseries" "s" {
        "平均" =
          "sum(increase(${duration}[$bucket])) / (sum(increase(${calls}[$bucket])) > 0)";
        P50 = "histogram_quantile(0.50, sum by (le) (increase(${buckets}[$bucket]))) > 0";
        P95 = "histogram_quantile(0.95, sum by (le) (increase(${buckets}[$bucket]))) > 0";
      })
      // {
        description = "对数纵轴同时展示正常耗时与异常长耗时，不截断极值。P50/P95 由直方图估计；低调用量下分位数仅供参考。";
      }
    )
    (panel 8 "错误次数 / $bucket · 按供应商与错误类型" "timeseries" "short" {
      "{{gen_ai.provider.name}} · {{error.type}}" =
        ''sum by ("gen_ai.provider.name", "error.type") (increase(${errors}[$bucket]))'';
    })
    (panel 9 "模型调用排行 · Top 15" "bargauge" "short" {
      "{{gen_ai.request.model}}" =
        ''topk(15, sum by ("gen_ai.request.model") (increase(${calls}[$__range])) > 0)'';
    })
    (
      (panel 10 "模型 Token 用量排行 · Top 15" "bargauge" "short" {
        "{{gen_ai.request.model}}" =
          ''topk(15, sum by ("gen_ai.request.model") (increase(${tokens}[$__range])) > 0)'';
      })
      // {
        description = "输入与输出 Token 合计；完整模型名显示在横向条形图左侧。输入、输出的时间分布见上方 Token 用量图。";
      }
    )
  ];
}
