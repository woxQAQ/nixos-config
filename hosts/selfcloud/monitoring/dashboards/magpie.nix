{ lib }:
let
  inherit (import ./lib.nix { inherit lib; }) mkDashboard mkPanel mkTarget;
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
  # Magpie exports DELTA histograms with aggregationTemporality=1.
  # VictoriaMetrics stores each batch unchanged. Sum the batches because
  # increase() would mistake a smaller batch for a counter reset.
  total = series: "sum(sum_over_time(${series}[$__range]))";
  totalCalls = total calls;
  totalErrors = "(${total errors} or (0 * ${totalCalls}))";
  byModel =
    series:
    ''sum by (model) (label_replace(sum_over_time(${series}[$__range]), "model", "$1", "gen_ai.request.model", "(.*)"))'';
  modelCalls = byModel calls;
  modelErrors = "(${byModel errors} or (0 * ${modelCalls}))";
  traceDatasource = {
    type = "tempo";
    uid = "victoriatraces-metrics";
  };
  # Use the same spans for cache totals and hit rate, including zero cache usage.
  # Parent spans have no usage attributes and do not count toward either total.
  # Raw TraceQL strings preserve the backslashes from Grafana's regex formatter.
  traceSelector = ''{ resource.service.name = "magpie" && span.gen_ai.provider.name =~ `''${provider:regex}` && span.gen_ai.request.model =~ `''${model:regex}` && span.magpie.agent =~ `''${agent:regex}` && span.gen_ai.usage.cache_read.input_tokens >= 0 && span.gen_ai.usage.cache_creation.input_tokens >= 0 && span.gen_ai.usage.input_tokens >= 0 }'';
  traceTarget = refId: attribute: {
    inherit refId;
    datasource = traceDatasource;
    queryType = "traceql";
    metricsQueryType = "range";
    query = "${traceSelector} | sum_over_time(span.gen_ai.usage.${attribute})";
    # Tempo sends step without expanding variables. Omit it so VictoriaTraces
    # chooses the bucket size for the requested time range.
    filters = [ ];
    exemplars = 0;
  };
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
  target =
    refId: expr: legendFormat:
    mkTarget {
      inherit refId expr legendFormat;
    };
  panel =
    id: title: type: unit: gridPos: targets:
    mkPanel {
      inherit
        id
        title
        type
        datasource
        gridPos
        ;
      unit = if unit == "short" then "locale" else unit;
      interval = "$bucket";
      fieldConfig.defaults = {
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
          axisLabel = if unit == "s" then "耗时 · 对数刻度" else "窗口内数量";
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
  # Tempo returns non-overlapping buckets. Sum all buckets for each total,
  # then divide the cache-read total by the input total for the hit rate.
  tracePanel =
    id: title: type: unit: gridPos: targets:
    lib.recursiveUpdate
      (builtins.removeAttrs (panel id title type unit gridPos [ ]) [ "interval" ])
      {
        datasource = traceDatasource;
        inherit targets;
        description = "按顶部条件筛选已保存的模型调用 Trace。只统计同时带有缓存读写和输入 Token 字段的 span。时间按 span 开始时刻计算，与 Metrics 的批次上报时间可能不同。";
        options.reduceOptions.calcs = [ "sum" ];
        fieldConfig.defaults.noValue = "无数据";
        transformations = [ traceSamplesOnly ];
      };
  # VictoriaTraces returns exemplar frames even with exemplars=0. They carry
  # repeated bucket values and must not participate in token totals.
  traceSamplesOnly = {
    id = "filterFrames";
    options.exclude = {
      id = "byName";
      options = "exemplar";
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
mkDashboard {
  uid = "selfcloud-magpie";
  title = "Magpie · 模型用量";
  description = "总量、占比和明细按所选时间范围统计。Metrics 按批次上报时间统计，调用趋势使用所选粒度。缓存用量和 Token 趋势来自已保存的 Trace，Token 趋势使用自动粒度。调用次数可能包含路由重试，输入 Token 包含重复上下文。";
  version = 6;
  tags = [
    "selfcloud"
    "magpie"
    "gen-ai"
  ];
  graphTooltip = 1;
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

    (tracePanel 16 "缓存读取 Token · Trace" "stat" "short" (grid 0 5 8 4) [
      (traceTarget "A" "cache_read.input_tokens")
    ])
    (tracePanel 17 "缓存写入 Token · Trace" "stat" "short" (grid 8 5 8 4) [
      (traceTarget "A" "cache_creation.input_tokens")
    ])
    (lib.recursiveUpdate
      (tracePanel 18 "Token 缓存命中率 · Trace" "stat" "percentunit" (grid 16 5 8 4) [
        (traceTarget "A" "cache_read.input_tokens")
        (traceTarget "B" "input_tokens")
      ])
      {
        description = "先分别汇总同一组 span 的缓存读取和完整输入 Token，再计算缓存读取占输入的比例。完整输入包含缓存读写。输入为零时显示无输入。只统计已保存且带有缓存字段的 Trace。";
        transformations = [
          traceSamplesOnly
          {
            id = "reduce";
            options = {
              mode = "reduceFields";
              reducers = [ "sum" ];
            };
          }
        ]
        ++
          map
            ({ refId, name }: {
              id = "renameByRegex";
              filter = {
                id = "byRefId";
                options = refId;
              };
              options = {
                regex = ".*";
                renamePattern = name;
              };
            })
            [
              {
                refId = "A";
                name = "缓存读取";
              }
              {
                refId = "B";
                name = "完整输入";
              }
            ]
        ++ [
          {
            id = "concatenate";
            options.frameNameMode = "drop";
          }
          {
            id = "calculateField";
            options = {
              mode = "binary";
              binary = {
                left.matcher = {
                  id = "byName";
                  options = "缓存读取";
                };
                operator = "/";
                right.matcher = {
                  id = "byName";
                  options = "完整输入";
                };
              };
              alias = "缓存命中率";
              replaceFields = true;
            };
          }
        ];
        fieldConfig.defaults = {
          decimals = 2;
          mappings = [
            {
              type = "special";
              options = {
                match = "nan";
                result.text = "无输入";
              };
            }
          ];
        };
      }
    )

    (row 101 "用量分布" 9)
    (panel 7 "模型 Token 占比" "piechart" "short" (grid 0 10 12 9) [
      (target "A" "${byModel tokens} > 0" "{{model}}")
    ])
    (panel 8 "供应商调用占比" "piechart" "short" (grid 12 10 6 9) [
      (target "A"
        ''sum by ("gen_ai.provider.name") (sum_over_time(${calls}[$__range])) > 0''
        "{{gen_ai.provider.name}}"
      )
    ])
    (panel 9 "Agent 调用占比" "piechart" "short" (grid 18 10 6 9) [
      (target "A" ''sum by ("magpie.agent") (sum_over_time(${calls}[$__range])) > 0''
        "{{magpie.agent}}"
      )
    ])

    (row 102 "模型明细" 19)
    (lib.recursiveUpdate
      (panel 10 "模型调用、Token 与延迟" "table" "short" (grid 0 20 24 10) [
        (target "A" modelCalls "调用次数")
        (target "B" (byModel input) "输入 Token")
        (target "C" (byModel output) "输出 Token")
        (target "D" modelErrors "错误次数")
        (target "E" "${modelErrors} / (${modelCalls} > 0)" "错误率")
        (target "F" "${byModel duration} / (${modelCalls} > 0)" "平均耗时")
      ])
      {
        description = "按所选时间范围和筛选条件统计。空白表示缺少指标。平均耗时包含异常长调用，不代表实际编码时间。";
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

    (row 103 "调用与 Token 趋势" 30)
    (panel 11 "调用次数 / $bucket · 按模型" "timeseries" "short" (grid 0 31 12 9) [
      (target "A"
        ''sum by ("gen_ai.request.model") (sum_over_time(${calls}[$bucket]))''
        "{{gen_ai.request.model}}"
      )
    ])
    (lib.recursiveUpdate
      (tracePanel 12 "Token 用量 · Trace · 自动粒度" "timeseries" "short" (grid 12 31 12 9)
        [
          (traceTarget "A" "input_tokens")
          (traceTarget "B" "output_tokens")
          (traceTarget "C" "cache_read.input_tokens")
          (traceTarget "D" "cache_creation.input_tokens")
        ]
      )
      {
        description = "按已保存的模型调用 Trace 统计，使用自动时间粒度。左柱堆叠输入和输出，右柱堆叠缓存读取和写入。输入已包含缓存读写，两根柱子不能相加。顶部供应商、模型和 Agent 筛选均生效。";
        fieldConfig.defaults.custom.axisLabel = "窗口内 Token · 自动粒度";
        options.legend.calcs = [ "sum" ];
        fieldConfig.overrides =
          map
            (
              {
                refId,
                name,
                group,
                alignment,
              }:
              {
                matcher = {
                  id = "byFrameRefID";
                  options = refId;
                };
                properties = [
                  {
                    id = "displayName";
                    value = name;
                  }
                  {
                    id = "custom.stacking";
                    value = {
                      mode = "normal";
                      inherit group;
                    };
                  }
                  {
                    id = "custom.barAlignment";
                    value = alignment;
                  }
                  {
                    id = "custom.barWidthFactor";
                    value = 0.45;
                  }
                ];
              }
            )
            [
              {
                refId = "A";
                name = "输入，含缓存";
                group = "用量";
                alignment = -1;
              }
              {
                refId = "B";
                name = "输出";
                group = "用量";
                alignment = -1;
              }
              {
                refId = "C";
                name = "缓存读取";
                group = "缓存";
                alignment = 1;
              }
              {
                refId = "D";
                name = "缓存写入";
                group = "缓存";
                alignment = 1;
              }
            ];
      }
    )

    (row 104 "延迟与可靠性" 40)
    (
      (panel 13 "调用耗时 / $bucket" "timeseries" "s" (grid 0 41 12 9) [
        (target "A"
          "sum(sum_over_time(${duration}[$bucket])) / (sum(sum_over_time(${calls}[$bucket])) > 0)"
          "平均"
        )
        (target "B"
          "histogram_quantile(0.50, sum by (le) (sum_over_time(${buckets}[$bucket]))) > 0"
          "P50"
        )
        (target "C"
          "histogram_quantile(0.95, sum by (le) (sum_over_time(${buckets}[$bucket]))) > 0"
          "P95"
        )
      ])
      // {
        description = "纵轴使用对数刻度，包含异常长调用。没有调用时不显示耗时。P50 和 P95 由直方图估算，调用量少时误差较大。";
      }
    )
    (panel 14 "错误次数 / $bucket" "timeseries" "short" (grid 12 41 12 9) [
      (target "A"
        ''sum by ("gen_ai.provider.name", "error.type") (sum_over_time(${errors}[$bucket]))''
        "{{gen_ai.provider.name}} · {{error.type}}"
      )
    ])
    (lib.recursiveUpdate
      (panel 15 "错误汇总" "table" "short" (grid 0 50 24 8) [
        (target "A"
          ''sort_desc(sum by ("gen_ai.provider.name", "gen_ai.request.model", "error.type") (sum_over_time(${errors}[$__range])) > 0)''
          "错误次数"
        )
      ])
      {
        description = "按供应商、模型和错误类型统计次数。指标不含每次请求的错误消息。";
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
