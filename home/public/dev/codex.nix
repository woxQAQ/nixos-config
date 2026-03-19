{
  config,
  lib,
  osConfig,
  pkgs,
  ...
}:
let
  pythonWithTomlkit = pkgs.python3.withPackages (ps: [ ps.tomlkit ]);
  grafanaStackEnabled = lib.all (path: lib.attrByPath path false osConfig) [
    [
      "services"
      "grafana"
      "enable"
    ]
    [
      "services"
      "victorialogs"
      "enable"
    ]
    [
      "services"
      "victoriatraces"
      "enable"
    ]
  ];
  vlogsEndpoint = "http://127.0.0.1:9428/insert/opentelemetry/v1/logs";
  vtraceEndpoint = "http://127.0.0.1:10428/insert/opentelemetry/v1/traces";

  vmmetrics_endpoint = "http://127.0.0.1:8428/opentelemetry/v1/metrics";
  codexConfigActivationScript = pkgs.writeText "codex-config-activation.py" ''
    import os
    from pathlib import Path

    import tomlkit


    config_path = Path(os.environ["CODEX_CONFIG_PATH"]).expanduser()
    grafana_stack_enabled = os.environ["CODEX_GRAFANA_STACK_ENABLED"] == "1"
    logs_endpoint = os.environ["CODEX_VLOGS_ENDPOINT"]
    traces_endpoint = os.environ["CODEX_VTRACE_ENDPOINT"]
    vmmetrics_endpoint = os.environ["CODEX_VMMETRICS_ENDPOINT"]

    file_existed = config_path.exists()
    store_managed_symlink = config_path.is_symlink() and str(config_path.resolve()).startswith("/nix/store/")

    if grafana_stack_enabled or file_existed or store_managed_symlink:
        config_path.parent.mkdir(parents=True, exist_ok=True)

    if store_managed_symlink:
        config_path.unlink()

    document = tomlkit.document()
    if file_existed:
        raw = config_path.read_text(encoding="utf-8")
        if raw.strip():
            document = tomlkit.parse(raw)

    otel = document.get("otel")
    if grafana_stack_enabled:
        if otel is None or not hasattr(otel, "items"):
            otel = tomlkit.table()
            document["otel"] = otel

        otel["log_user_prompt"] = True
        otel["exporter"] = tomlkit.item(
            {
                "otlp-http": {
                    "endpoint": logs_endpoint,
                    "protocol": "binary",
                }
            }
        )
        otel["metrics_exporter"] = tomlkit.item (
          {
            "otlp-http": {
              "endpoint": vmmetrics_endpoint,
              "protocol": "binary",
            }
          }
        )
        otel["trace_exporter"] = tomlkit.item(
            {
                "otlp-http": {
                    "endpoint": traces_endpoint,
                    "protocol": "binary",
                }
            }
        )
    elif hasattr(otel, "pop"):
        otel.pop("exporter", None)
        otel.pop("trace-exporter", None)
        otel.pop("log_user_prompt", None)
        if len(otel) == 0:
            document.pop("otel", None)

    if grafana_stack_enabled or file_existed:
        config_path.write_text(tomlkit.dumps(document), encoding="utf-8")
  '';
in
{
  home.packages = with pkgs; [
    antigravity-fhs
  ];

  # Reconcile only the Codex OTEL keys at switch time so the file stays mutable.
  home.activation.codexConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    export CODEX_CONFIG_PATH=${lib.escapeShellArg "${config.home.homeDirectory}/.codex/config.toml"}
    export CODEX_GRAFANA_STACK_ENABLED=${lib.escapeShellArg (if grafanaStackEnabled then "1" else "0")}
    export CODEX_VLOGS_ENDPOINT=${lib.escapeShellArg vlogsEndpoint}
    export CODEX_VTRACE_ENDPOINT=${lib.escapeShellArg vtraceEndpoint}
    export CODEX_VMMETRICS_ENDPOINT=${lib.escapeShellArg vmmetrics_endpoint}
    run ${pythonWithTomlkit}/bin/python ${codexConfigActivationScript}
  '';
}
