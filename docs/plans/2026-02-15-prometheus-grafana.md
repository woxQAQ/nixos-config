# Prometheus + Grafana Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Add system monitoring with Prometheus and visualization with Grafana to the NixOS configuration.

**Architecture:** Create a new monitoring module under `modules/x86_64-linux/system/` that configures Prometheus with node_exporter for system metrics, and Grafana with Prometheus datasource and pre-configured dashboards. The module will be enable/disable through the existing module option pattern used throughout the codebase.

**Tech Stack:**
- NixOS modules (services.prometheus, services.grafana)
- Prometheus (metrics collection)
- Grafana (visualization)
- node_exporter (system metrics exporter)

---

## Task 1: Create the monitoring module structure

**Files:**
- Create: `modules/x86_64-linux/system/monitoring.nix`
- Modify: `modules/x86_64-linux/system/default.nix`

**Step 1: Create the monitoring module file**

Write the base monitoring module structure:

```nix
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.modules.system.monitoring;
in
{
  options.modules.system.monitoring = {
    enable = lib.mkEnableOption "Enable system monitoring with Prometheus and Grafana";
  };

  config = lib.mkIf cfg.enable {
    # Prometheus and Grafana configuration will go here
  };
}
```

**Step 2: Add monitoring module to system imports**

Add `./monitoring.nix` to the imports list:

```nix
{ ... }:
{
  imports = [
    ./locale.nix
    ./net.nix
    ./zram.nix
    ./system.nix
    ./misc.nix
    ./user.nix
    ./security.nix
    ./fhs.nix
    ./ssh.nix
    ./environment.nix
    ./optimization.nix
    ./monitoring.nix  # Add this line
  ];
}
```

**Step 3: Verify module compiles**

Run: `nix flake check`

Expected: No errors about `modules.system.monitoring` option

**Step 4: Commit**

```bash
git add modules/x86_64-linux/system/monitoring.nix modules/x86_64-linux/system/default.nix
git commit -m "feat: add monitoring module structure"
```

---

## Task 2: Configure Prometheus

**Files:**
- Modify: `modules/x86_64-linux/system/monitoring.nix`

**Step 1: Add Prometheus service configuration**

Add Prometheus configuration to the module:

```nix
  config = lib.mkIf cfg.enable {
    services.prometheus = {
      enable = true;
      port = 9090;
      globalConfig = {
        scrape_interval = "15s";
        evaluation_interval = "15s";
      };
      scrapeConfigs = [
        {
          job_name = "node";
          static_configs = [
            {
              targets = [ "127.0.0.1:${toString config.services.prometheus.exporters.node.port}" ];
            }
          ];
        }
      ];
      exporters = {
        node = {
          enable = true;
          enabledCollectors = [
            "systemd"
            "processes"
            "filesystem"
            "hwmon"
            "network"
            "stat"
          ];
          port = 9100;
        };
      };
    };

    # Open firewall for Prometheus
    networking.firewall.allowedTCPPorts = [ 9090 9100 ];
  };
```

**Step 2: Verify configuration compiles**

Run: `nix flake check`

Expected: No errors

**Step 3: Commit**

```bash
git add modules/x86_64-linux/system/monitoring.nix
git commit -m "feat: add Prometheus configuration with node_exporter"
```

---

## Task 3: Configure Grafana

**Files:**
- Modify: `modules/x86_64-linux/system/monitoring.nix`

**Step 1: Add Grafana service configuration**

Add Grafana configuration to the module (inside the `config = lib.mkIf cfg.enable` block, after the Prometheus config):

```nix
    services.grafana = {
      enable = true;
      settings = {
        server = {
          http_port = 3000;
          root_url = "http://localhost:3000";
        };
        security = {
          admin_user = "admin";
          # IMPORTANT: Change this after first login!
          # Using agenix for secrets would be better in production
          admin_password = "admin";
        };
      };
      provision = {
        datasources.settings.datasources = [
          {
            name = "Prometheus";
            type = "prometheus";
            url = "http://localhost:9090";
            isDefault = true;
          }
        ];
        dashboards.settings.providers = [
          {
            name = "Node Exporter";
            options.path = pkgs.grafana-dashboards-node-exporter;
          }
          {
            name = "Prometheus";
            options.path = pkgs.grafana-dashboards-prometheus;
          }
        ];
      };
    };

    # Open firewall for Grafana
    networking.firewall.allowedTCPPorts = [ 3000 ];
```

**Note:** You'll need to update the firewall ports list to include all three ports (9090, 9100, 3000). The previous task's firewall config should be merged with this one.

**Step 2: Merge firewall port configuration**

Update the firewall config to include all ports in one line:

```nix
    networking.firewall.allowedTCPPorts = [ 3000 9090 9100 ];
```

**Step 3: Verify configuration compiles**

Run: `nix flake check`

Expected: No errors

**Step 4: Commit**

```bash
git add modules/x86_64-linux/system/monitoring.nix
git commit -m "feat: add Grafana configuration with Prometheus datasource"
```

---

## Task 4: Enable monitoring for the host

**Files:**
- Modify: `outputs/woxQAQ.nix`

**Step 1: Enable the monitoring module**

Add monitoring enable to the host config:

```nix
  nixos-modules = [
    inputs.agenix.nixosModules.default
    inputs.dae.nixosModules.dae
    inputs.dae.nixosModules.daed
    ../secrets
    ../hosts/${name}
    ../modules/${system}/system
    ../modules/${system}/desktop
    ../modules/${system}/packages
    ../modules/${system}/boot
    ../modules/public
  ]
  ++ [
    {
      modules.desktop.game.enable = true;
      modules.desktop.flatpak-apps.enable = true;
      modules.system.monitoring.enable = true;  # Add this line
    }
  ];
```

**Step 2: Verify configuration compiles**

Run: `nix flake check`

Expected: No errors

**Step 3: Commit**

```bash
git add outputs/woxQAQ.nix
git commit -m "feat: enable monitoring for woxQAQ host"
```

---

## Task 5: Test the deployment

**Files:**
- None (testing step)

**Step 1: Build and switch the configuration**

Run: `make switch`

Expected: Build completes successfully, services start

**Step 2: Verify Prometheus is running**

Run: `systemctl status prometheus.service`

Expected: Service is active (running)

**Step 3: Verify node_exporter is running**

Run: `systemctl status prometheus-node-exporter.service`

Expected: Service is active (running)

**Step 4: Verify Grafana is running**

Run: `systemctl status grafana.service`

Expected: Service is active (running)

**Step 5: Check Prometheus targets**

Run: `curl -s http://localhost:9090/api/v1/targets | jq '.data.activeTargets[] | {job: .labels.job, health: .health}'`

Expected: Returns job "node" with health "up"

**Step 6: Test Grafana web interface**

Run: `curl -s http://localhost:3000/api/health | jq`

Expected: Returns `{"commit":..., "database":"ok", "version":"..."}`

**Step 7: Open Grafana in browser**

Run: `xdg-open http://localhost:3000`

Expected: Grafana web interface opens, login with admin/admin

**Step 8: Verify Prometheus datasource**

In Grafana UI:
1. Go to Configuration → Data Sources
2. Click "Prometheus"
3. Click "Test"

Expected: Shows "Data source is working"

**Step 9: Commit successful deployment**

```bash
git commit --allow-empty -m "test: verify Prometheus and Grafana deployment successful"
```

---

## Task 6: Add documentation

**Files:**
- Modify: `CLAUDE.md`

**Step 1: Add monitoring section to CLAUDE.md**

Add a new section after "Common Operations":

```markdown
## Monitoring

The configuration includes optional system monitoring with Prometheus and Grafana.

**Enable monitoring:**

Set `modules.system.monitoring.enable = true;` in your host's flake output file (e.g., `outputs/<hostname>.nix`).

**Access points:**
- Prometheus: http://localhost:9090
- Grafana: http://localhost:3000 (default credentials: admin/admin)

**Included exporters:**
- node_exporter (port 9100) - System metrics (CPU, memory, disk, network)
- Pre-configured Grafana dashboards for Node Exporter and Prometheus

**Firewall ports:**
- 3000 - Grafana web interface
- 9090 - Prometheus metrics endpoint
- 9100 - node_exporter metrics

**Security note:** Change the default Grafana admin password after first login. For production, use agenix to manage secrets.
```

**Step 2: Commit documentation**

```bash
git add CLAUDE.md
git commit -m "docs: add monitoring section to CLAUDE.md"
```

---

## Task 7: Optional security improvements

**Files:**
- Modify: `modules/x86_64-linux/system/monitoring.nix`
- Create: `secrets/grafana-admin-password.age` (if using agenix)

**Step 1: Check if agenix is available for secrets**

Run: `nix run github:ryantm/agenix -- --version`

Expected: Agenix runs and shows version

**Step 2: Create Grafana secret password (optional, if using agenix)**

Generate a secure password:

```bash
# Generate secure password
openssl rand -base64 32

# Encrypt it with agenix (replace YOUR_PASSWORD with actual password)
echo "YOUR_PASSWORD" | nix run github:ryantm/agenix -- --edit ../secrets/grafana-admin-password.age
```

**Step 3: Update Grafana config to use agenix secret**

Modify the Grafana security section:

```nix
        security = {
          admin_user = "admin";
          admin_password = config.age.secrets.grafana-admin-password.path or "admin";
        };
```

And add the secret configuration:

```nix
    age.secrets.grafana-admin-password = lib.mkIf (cfg.enable && config.age.secrets ? grafana-admin-password) {
      file = ../secrets/grafana-admin-password.age;
      owner = "grafana";
      group = "grafana";
    };
```

**Step 4: Document this as optional**

Add to CLAUDE.md monitoring section:

```markdown
**Optional: Secure Grafana password with agenix:**

1. Create encrypted secret: `openssl rand -base64 32 | nix run github:ryantm/agenix -- --edit secrets/grafana-admin-password.age`
2. Add secret to host's secrets list in `outputs/<hostname>.nix`
3. The monitoring module will automatically use the secret if available
```

**Step 5: Commit security improvements**

```bash
git add modules/x86_64-linux/system/monitoring.nix CLAUDE.md
git commit -m "feat(security): add optional agenix support for Grafana password"
```

---

## Summary

This plan creates a complete monitoring solution:

1. **Module structure** - Follows existing codebase patterns
2. **Prometheus** - Metrics collection with 15s scrape interval
3. **node_exporter** - System metrics (CPU, memory, disk, network, processes, systemd)
4. **Grafana** - Web UI with pre-configured dashboards and datasources
5. **Security** - Opens necessary firewall ports, optional agenix integration
6. **Documentation** - Updated CLAUDE.md with usage instructions

**Testing checklist:**
- [ ] `nix flake check` passes
- [ ] `make switch` completes successfully
- [ ] All services running (prometheus, prometheus-node-exporter, grafana)
- [ ] Prometheus scraping node_exporter successfully
- [ ] Grafana accessible at localhost:3000
- [ ] Prometheus datasource working in Grafana
- [ ] Dashboards visible and displaying data

**Future enhancements:**
- Add alertmanager for alerting
- Add more exporters (process_exporter, postgres_exporter, etc.)
- Configure retention policies
- Set up backup for Grafana dashboards
- Add authentication reverse proxy
