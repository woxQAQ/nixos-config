{ lib }:
let
  datasource = {
    type = "prometheus";
    uid = "selfcloud-storage";
  };
  # OTLP ingestion preserves dots in metric and label names.
  identity = ''"service.name"="magpie","scope.name"="github.com/yetone/magpie"'';
  # Use the datasource formatter so regex values are also escaped as PromQL strings.
  selector = ''${identity},"gen_ai.provider.name"=~"$provider","gen_ai.request.model"=~"$model","magpie.agent"=~"$agent"'';
  metric = name: extra: ''{"${name}",${selector}${extra}}'';
  calls = metric "gen_ai.client.operation.duration_count" "";
  errors = metric "gen_ai.client.operation.duration_count" '',"error.type"!=""'';
  duration = metric "gen_ai.client.operation.duration_sum" "";
  buckets = metric "gen_ai.client.operation.duration_bucket" "";
  tokens = metric "gen_ai.client.token.usage_sum" "";
  input = metric "gen_ai.client.token.usage_sum" '',"gen_ai.token.type"="input"'';
  output = metric "gen_ai.client.token.usage_sum" '',"gen_ai.token.type"="output"'';
  total = series: "sum(increase(${series}[$__range]))";
  totalCalls = total calls;
  totalErrors = "(${total errors} or (0 * ${totalCalls}))";
  byModel =
    series:
    ''sum by (model) (label_replace(increase(${series}[$__range]), "model", "$1", "gen_ai.request.model", "(.*)"))'';
  modelCalls = byModel calls;
  modelErrors = "(${byModel errors} or (0 * ${modelCalls}))";
  grid = x: y: w: h: {
    inherit
      x
      y
      w
      h
      ;
  };
  row = id: title: y: {
    inherit id title;
    type = "row";
    collapsed = false;
    panels = [ ];
    gridPos = grid 0 y 24 1;
  };
  target = refId: expr: legendFormat: {
    inherit refId expr legendFormat;
  };
  panel = id: title: type: unit: gridPos: targets: {
    inherit
      id
      title
      type
      datasource
      gridPos
      ;
    interval = "$bucket";
    fieldConfig.defaults = {
      unit = if unit == "short" then "locale" else unit;
      min = if unit == "s" then 0.001 else 0;
      color.mode = "palette-classic";
    }
    // lib.optionalAttrs (unit == "short") { decimals = 0; }
    // lib.optionalAttrs (unit == "percentunit") { max = 1; }
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
        scaleDistribution =
          if unit == "s" then
            {
              type = "log";
              log = 10;
            }
          else
            { type = "linear"; };
        axisLabel = if unit == "s" then "耗时（对数刻度）" else "窗口内数量";
      };
    };
    options =
      if type == "timeseries" then
        {
          tooltip = {
            mode = "multi";
            sort = "desc";
          };
          legend = {
            showLegend = true;
            displayMode = "table";
            placement = "bottom";
            calcs = [ "max" ];
          };
        }
      else if type == "piechart" then
        {
          pieType = "donut";
          sort = "desc";
          reduceOptions = {
            calcs = [ "lastNotNull" ];
            values = false;
          };
          legend = {
            showLegend = true;
            displayMode = "table";
            placement = "right";
            values = [
              "value"
              "percent"
            ];
          };
          tooltip.mode = "single";
        }
      else if type == "table" then
        {
          showHeader = true;
          cellHeight = "sm";
          sortBy = [
            {
              displayName = "调用次数";
              desc = true;
            }
          ];
        }
      else
        {
          colorMode = "value";
          graphMode = "none";
          justifyMode = "center";
          reduceOptions.calcs = [ "lastNotNull" ];
        };
    targets = map (
      query:
      query
      // {
        instant = type != "timeseries";
        range = type == "timeseries";
        format = if type == "table" then "table" else "time_series";
      }
    ) targets;
  };
  stat =
    id: title: x: unit: color: expression:
    lib.recursiveUpdate
      (panel id title "stat" unit (grid x 1 4 4) [ (target "A" expression title) ])
      {
        fieldConfig.defaults.color = {
          mode = "fixed";
          fixedColor = color;
        };
      };
  variable = name: label: sourceLabel: {
    inherit name label datasource;
    type = "query";
    refresh = 2;
    sort = 1;
    multi = true;
    includeAll = true;
    allValue = ".*";
    current = {
      text = "全部";
      value = [ "$__all" ];
    };
    # A plain output label avoids Grafana's legacy label_values parser for dotted labels.
    query = {
      query = ''query_result(count by (option) (label_replace(count_over_time({"gen_ai.client.operation.duration_count",${identity}}[$__range]), "option", "$1", "${sourceLabel}", "(.*)")))'';
      refId = "${name}Variable";
    };
    regex = ''/option="([^"]+)"/'';
  };
in
{
  uid = "selfcloud-magpie";
  title = "Magpie · 模型用量";
  description = "调用与 Token 用量分析。总量、占比和明细按所选时间范围统计，趋势按统计粒度展示窗口增量。调用可能包含路由重试；输入 Token 包含重复上下文。";
  schemaVersion = 39;
  version = 3;
  tags = [
    "selfcloud"
    "magpie"
    "gen-ai"
  ];
  timezone = "browser";
  graphTooltip = 1;
  refresh = "1m";
  time = {
    from = "now-7d";
    to = "now";
  };
  # Layout references: Grafana dashboards 25052 (revision 2) and 25255 (revision 10).
  templating.list = [
    (variable "provider" "供应商" "gen_ai.provider.name")
    (variable "model" "模型" "gen_ai.request.model")
    (variable "agent" "Agent" "magpie.agent")
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
    (row 100 "用量概览" 0)
    (stat 1 "调用总数" 0 "short" "blue" totalCalls)
    (stat 2 "错误次数" 4 "short" "red" totalErrors)
    (stat 3 "错误率" 8 "percentunit" "orange" "${totalErrors} / (${totalCalls} > 0)")
    (stat 4 "Token 总量" 12 "short" "purple" (total tokens))
    (stat 5 "输入 Token" 16 "short" "blue" (total input))
    (stat 6 "输出 Token" 20 "short" "green" (total output))

    (row 101 "用量分布" 5)
    (panel 7 "模型 Token 占比" "piechart" "short" (grid 0 6 12 9) [
      (target "A" "${byModel tokens} > 0" "{{model}}")
    ])
    (panel 8 "供应商调用占比" "piechart" "short" (grid 12 6 6 9) [
      (target "A"
        ''sum by ("gen_ai.provider.name") (increase(${calls}[$__range])) > 0''
        "{{gen_ai.provider.name}}"
      )
    ])
    (panel 9 "Agent 调用占比" "piechart" "short" (grid 18 6 6 9) [
      (target "A" ''sum by ("magpie.agent") (increase(${calls}[$__range])) > 0''
        "{{magpie.agent}}"
      )
    ])

    (row 102 "模型明细" 15)
    (lib.recursiveUpdate
      (panel 10 "模型调用、Token 与延迟" "table" "short" (grid 0 16 24 10) [
        (target "A" modelCalls "调用次数")
        (target "B" (byModel input) "输入 Token")
        (target "C" (byModel output) "输出 Token")
        (target "D" modelErrors "错误次数")
        (target "E" "${modelErrors} / (${modelCalls} > 0)" "错误率")
        (target "F" "${byModel duration} / (${modelCalls} > 0)" "平均耗时")
      ])
      {
        description = "各列均按所选时间范围与筛选条件计算。空白表示没有该指标；平均耗时保留异常值，不能视作活跃编码时间。";
        transformations = [
          {
            id = "joinByField";
            options = {
              byField = "model";
              mode = "outerTabular";
            };
          }
          {
            id = "filterFieldsByName";
            options.include.names = [
              "model"
              "Value #A"
              "Value #B"
              "Value #C"
              "Value #D"
              "Value #E"
              "Value #F"
            ];
          }
          {
            id = "organize";
            options = {
              indexByName = {
                model = 0;
                "Value #A" = 1;
                "Value #B" = 2;
                "Value #C" = 3;
                "Value #D" = 4;
                "Value #E" = 5;
                "Value #F" = 6;
              };
              renameByName = {
                model = "模型";
                "Value #A" = "调用次数";
                "Value #B" = "输入 Token";
                "Value #C" = "输出 Token";
                "Value #D" = "错误次数";
                "Value #E" = "错误率";
                "Value #F" = "平均耗时";
              };
            };
          }
        ];
        fieldConfig.overrides = [
          {
            matcher = {
              id = "byName";
              options = "模型";
            };
            properties = [
              {
                id = "custom.width";
                value = 420;
              }
            ];
          }
          {
            matcher = {
              id = "byName";
              options = "错误率";
            };
            properties = [
              {
                id = "unit";
                value = "percentunit";
              }
              {
                id = "decimals";
                value = 2;
              }
            ];
          }
          {
            matcher = {
              id = "byName";
              options = "平均耗时";
            };
            properties = [
              {
                id = "unit";
                value = "s";
              }
              {
                id = "decimals";
                value = 2;
              }
            ];
          }
        ];
      }
    )

    (row 103 "调用与 Token 趋势" 26)
    (panel 11 "调用次数 / $bucket · 按模型" "timeseries" "short" (grid 0 27 12 9) [
      (target "A" ''sum by ("gen_ai.request.model") (increase(${calls}[$bucket]))''
        "{{gen_ai.request.model}}"
      )
    ])
    (panel 12 "Token 用量 / $bucket" "timeseries" "short" (grid 12 27 12 9) [
      (target "A" "sum(increase(${input}[$bucket]))" "输入")
      (target "B" "sum(increase(${output}[$bucket]))" "输出")
    ])

    (row 104 "延迟与可靠性" 36)
    (
      (panel 13 "调用耗时 / $bucket" "timeseries" "s" (grid 0 37 12 9) [
        (target "A"
          "sum(increase(${duration}[$bucket])) / (sum(increase(${calls}[$bucket])) > 0)"
          "平均"
        )
        (target "B"
          "histogram_quantile(0.50, sum by (le) (increase(${buckets}[$bucket]))) > 0"
          "P50"
        )
        (target "C"
          "histogram_quantile(0.95, sum by (le) (increase(${buckets}[$bucket]))) > 0"
          "P95"
        )
      ])
      // {
        description = "对数纵轴保留异常长耗时；无调用时不显示延迟。分位数由直方图估计，低调用量时仅供参考。";
      }
    )
    (panel 14 "错误次数 / $bucket" "timeseries" "short" (grid 12 37 12 9) [
      (target "A"
        ''sum by ("gen_ai.provider.name", "error.type") (increase(${errors}[$bucket]))''
        "{{gen_ai.provider.name}} · {{error.type}}"
      )
    ])
    (lib.recursiveUpdate
      (panel 15 "错误汇总" "table" "short" (grid 0 46 24 8) [
        (target "A"
          ''sort_desc(sum by ("gen_ai.provider.name", "gen_ai.request.model", "error.type") (increase(${errors}[$__range])) > 0)''
          "错误次数"
        )
      ])
      {
        description = "按供应商、模型与错误类型聚合计数；指标不包含逐次请求的错误消息。";
        options.sortBy = [
          {
            displayName = "错误次数";
            desc = true;
          }
        ];
        transformations = [
          {
            id = "organize";
            options = {
              excludeByName.Time = true;
              indexByName = {
                "gen_ai.provider.name" = 0;
                "gen_ai.request.model" = 1;
                "error.type" = 2;
                Value = 3;
              };
              renameByName = {
                "gen_ai.provider.name" = "供应商";
                "gen_ai.request.model" = "模型";
                "error.type" = "错误类型";
                Value = "错误次数";
              };
            };
          }
        ];
      }
    )
  ];
}
