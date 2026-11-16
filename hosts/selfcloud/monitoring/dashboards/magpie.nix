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
      min = 0;
    }
    // lib.optionalAttrs (unit == "percentunit") { max = 1; };
    options = lib.optionalAttrs (type == "stat") {
      colorMode = "none";
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
  title = "Magpie";
  description = "Magpie OpenTelemetry metrics. Totals cover the selected time range; rates and latency use the rolling rate interval. Calls follow exported operation counts and may include routing attempts. No traffic leaves latency and error rate undefined. Token usage is the histogram sum, not its observation count; costs and cache breakdowns are not exported as metrics.";
  schemaVersion = 39;
  version = 1;
  tags = [
    "selfcloud"
    "magpie"
    "gen-ai"
  ];
  timezone = "browser";
  refresh = "30s";
  time = {
    from = "now-24h";
    to = "now";
  };
  panels = [
    (panel 1 "Calls · selected range" "stat" "short" {
      Calls = "sum(increase(${calls}[$__range]))";
    })
    (panel 2 "Error rate · selected range" "stat" "percentunit" {
      Errors = "(sum(increase(${errors}[$__range])) or (0 * sum(increase(${calls}[$__range])))) / sum(increase(${calls}[$__range]))";
    })
    (panel 3 "Input tokens · selected range" "stat" "short" {
      Input = ''sum(increase({"gen_ai.client.token.usage_sum",${selector},"gen_ai.token.type"="input"}[$__range]))'';
    })
    (panel 4 "Output tokens · selected range" "stat" "short" {
      Output = ''sum(increase({"gen_ai.client.token.usage_sum",${selector},"gen_ai.token.type"="output"}[$__range]))'';
    })
    (panel 5 "Calls per second by provider" "timeseries" "reqps" {
      "{{gen_ai.provider.name}}" =
        ''sum by ("gen_ai.provider.name") (rate(${calls}[$__rate_interval]))'';
    })
    (panel 6 "Tokens per second by type" "timeseries" "short" {
      "{{gen_ai.token.type}}" =
        ''sum by ("gen_ai.token.type") (rate(${tokens}[$__rate_interval]))'';
    })
    (panel 7 "Operation latency" "timeseries" "s" {
      Mean = "sum(rate(${duration}[$__rate_interval])) / sum(rate(${calls}[$__rate_interval]))";
      P95 = "histogram_quantile(0.95, sum by (le) (rate(${buckets}[$__rate_interval])))";
    })
    (panel 8 "Errors per second by provider and type" "timeseries" "reqps" {
      "{{gen_ai.provider.name}} · {{error.type}}" =
        ''sum by ("gen_ai.provider.name", "error.type") (rate(${errors}[$__rate_interval]))'';
    })
    (panel 9 "Calls by model · selected range" "bargauge" "short" {
      "{{gen_ai.request.model}}" =
        ''sort_desc(sum by ("gen_ai.request.model") (increase(${calls}[$__range])))'';
    })
    (panel 10 "Tokens by model and type · selected range" "bargauge" "short" {
      "{{gen_ai.request.model}} · {{gen_ai.token.type}}" =
        ''sort_desc(sum by ("gen_ai.request.model", "gen_ai.token.type") (increase(${tokens}[$__range])))'';
    })
    (panel 11 "Mean latency by model" "timeseries" "s" {
      "{{gen_ai.request.model}}" =
        ''sum by ("gen_ai.request.model") (rate(${duration}[$__rate_interval])) / sum by ("gen_ai.request.model") (rate(${calls}[$__rate_interval]))'';
    })
    (panel 12 "Calls per second by agent" "timeseries" "reqps" {
      "{{magpie.agent}}" =
        ''sum by ("magpie.agent") (rate(${calls}[$__rate_interval]))'';
    })
  ];
}
