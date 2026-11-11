# Integration tests for modules/x86_64-linux/services/monitoring.
#
# Run with:
#   nix eval --impure --json --expr 'import ./tests/monitoring.nix { flake = builtins.getFlake (toString ./.); }'
#
# Fixtures are minimal NixOS systems; they only evaluate module composition,
# so nothing here proves a running service.
{ flake }:
let
  inherit (flake.inputs.nixpkgs) lib;

  mkFixture =
    module:
    lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ../modules/x86_64-linux/services
        module
        {
          boot.loader.grub.enable = false;
          fileSystems."/" = {
            device = "/dev/invalid";
            fsType = "ext4";
          };
          system.stateVersion = "26.05";
        }
      ];
    };

  disabled = mkFixture { };

  hub = mkFixture {
    modules.services.monitoring = {
      enable = true;
      openFirewall = true;
      scrapeTargets = [
        {
          name = "selfcloud";
          address = "localhost:9100";
        }
        {
          name = "woxQAQ";
          address = "woxQAQ.lan:9100";
        }
      ];
    };
  };
  hubConfig = hub.config;

  storage = mkFixture {
    modules.services.monitoring = {
      enable = true;
      dataDir = "/data/apps";
    };
  };
  storageConfig = storage.config;

  customPorts = mkFixture {
    modules.services.monitoring = {
      enable = true;
      ports.metrics = 18428;
    };
  };
  customConfig = customPorts.config;

  datasourceUrls =
    cfg:
    map (
      ds: ds.url or null
    ) cfg.services.grafana.provision.datasources.settings.datasources;
in
{
  disabled =
    assert lib.assertMsg (
      !disabled.config.services.victoriametrics.enable
      && !disabled.config.services.victorialogs.enable
      && !disabled.config.services.victoriatraces.enable
      && !disabled.config.services.vmagent.enable
      && !disabled.config.services.grafana.enable
    ) "disabled: every hub service must stay off";
    true;

  hub =
    assert lib.assertMsg (
      hubConfig.services.victoriametrics.listenAddress == "0.0.0.0:8428"
      && hubConfig.services.victorialogs.listenAddress == "0.0.0.0:9428"
      && hubConfig.services.victoriatraces.listenAddress == "0.0.0.0:10428"
    ) "hub: the VictoriaMetrics family must bind the public ports";
    assert lib.assertMsg (
      hubConfig.services.vmagent.remoteWrite.url
      == "http://127.0.0.1:8428/api/v1/write"
    ) "hub: vmagent must remote-write into the local VictoriaMetrics";
    assert lib.assertMsg
      (
        hubConfig.services.vmagent.prometheusConfig.scrape_configs == [
          {
            job_name = "node-exporter";
            static_configs = [
              {
                targets = [ "localhost:9100" ];
                labels.host = "selfcloud";
              }
              {
                targets = [ "woxQAQ.lan:9100" ];
                labels.host = "woxQAQ";
              }
            ];
          }
        ]
      )
      "hub: scrape targets must render into vmagent's scrape config with host labels";
    assert lib.assertMsg (
      datasourceUrls hubConfig == [
        "http://127.0.0.1:8428"
        "" # infinity-dataviewer carries no URL
        "http://127.0.0.1:8428"
        "http://127.0.0.1:9428"
        "http://127.0.0.1:10428/select/jaeger"
      ]
    ) "hub: Grafana datasources must query the local VictoriaMetrics family";
    assert lib.assertMsg (
      hubConfig.services.grafana.provision.dashboards.settings == null
    ) "hub: dashboards are managed interactively, not provisioned";
    assert lib.assertMsg (
      lib.sort builtins.lessThan hubConfig.networking.firewall.allowedTCPPorts == [
        3000
        8428
        9428
        10428
      ]
    ) "hub: openFirewall must open exactly the hub ports";
    assert lib.assertMsg (
      !(hubConfig.systemd.services.victoriametrics.serviceConfig ? BindPaths)
    ) "hub: without dataDir no bind mounts may be configured";
    assert lib.assertMsg (
      hubConfig.services.grafana.dataDir == "/var/lib/grafana"
    ) "hub: without dataDir Grafana keeps its upstream state dir";
    true;

  relocatedStorage =
    assert lib.assertMsg (
      storageConfig.services.grafana.dataDir == "/data/apps/grafana"
    ) "relocatedStorage: Grafana must follow dataDir";
    assert lib.assertMsg
      (
        storageConfig.systemd.services.victoriametrics.serviceConfig.BindPaths
        == [ "/data/apps/victoriametrics:/var/lib/victoriametrics:rbind" ]
        &&
          storageConfig.systemd.services.victorialogs.serviceConfig.BindPaths
          == [ "/data/apps/victorialogs:/var/lib/victorialogs:rbind" ]
        &&
          storageConfig.systemd.services.victoriatraces.serviceConfig.BindPaths
          == [ "/data/apps/victoriatraces:/var/lib/victoriatraces:rbind" ]
      )
      "relocatedStorage: the VictoriaMetrics family must bind-mount relocated storage onto its StateDirectory";
    assert lib.assertMsg
      (
        lib.all
          (
            rule:
            lib.hasInfix "0770 root victoriametrics-" rule
            || lib.hasInfix "0770 root victoriametrics-data" rule
          )
          (
            lib.filter (
              rule: lib.hasPrefix "d /data/apps/" rule
            ) storageConfig.systemd.tmpfiles.rules
          )
        &&
          builtins.length (
            lib.filter (
              rule: lib.hasPrefix "d /data/apps/" rule
            ) storageConfig.systemd.tmpfiles.rules
          ) == 3
      )
      "relocatedStorage: tmpfiles must create one group-owned directory per service";
    true;

  portConsistency =
    assert lib.assertMsg
      (
        customConfig.services.victoriametrics.listenAddress == "0.0.0.0:18428"
        &&
          customConfig.services.vmagent.remoteWrite.url
          == "http://127.0.0.1:18428/api/v1/write"
        && lib.all (url: !(lib.hasInfix ":8428" url)) (datasourceUrls customConfig)
      )
      "portConsistency: overriding a port must propagate to listeners, vmagent and Grafana datasources";
    true;
}
