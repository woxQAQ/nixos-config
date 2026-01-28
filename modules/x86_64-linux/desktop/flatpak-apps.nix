{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.modules.desktop.flatpak-apps;
in
{
  options.modules.desktop.flatpak-apps = {
    enable = lib.mkEnableOption "Enable Flatpak Chinese applications management";

    chineseApps = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [
        "com.tencent.WeChat" # 微信
        "com.qq.QQ" # QQ
        "cn.feishu.Feishu" # 飞书
      ];
      description = "List of Flatpak applications to install from Flathub";
    };
  };

  config = lib.mkIf cfg.enable {
    services.flatpak = {
      enable = true;
    };

    # Add Flathub remote
    systemd.services.add-flathub = {
      description = "Add Flathub remote for Flatpak";
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${pkgs.flatpak}/bin/flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo";
        RemainAfterExit = true;
      };
    };

    # Configure Flatpak overrides for Chinese apps
    systemd.services.flatpak-overrides = {
      description = "Configure Flatpak overrides for Chinese applications";
      wantedBy = [ "multi-user.target" ];
      after = [
        "network.target"
        "add-flathub.service"
      ];
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${pkgs.bash}/bin/bash -c '${pkgs.flatpak}/bin/flatpak override com.tencent.WeChat --filesystem=home 2>/dev/null || true'";
        RemainAfterExit = true;
      };
    };

    # Create a script to install Chinese apps
    environment.systemPackages = with pkgs; [
      (writeShellScriptBin "install-chinese-apps" ''
        #!/usr/bin/env bash
        set -euo pipefail

        # Add Flathub if not exists
        echo "Adding Flathub remote..."
        flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

        # Install apps
        echo "Installing Chinese apps..."
        ${lib.concatMapStringsSep "\n" (app: ''
          echo "Installing ${app}..."
          flatpak install flathub ${app} --assumeyes || true
        '') cfg.chineseApps}

        echo "Done! You may need to log out and log back in."
      '')

      (writeShellScriptBin "update-chinese-apps" ''
        #!/usr/bin/env bash
        set -euo pipefail

        echo "Updating Flatpak apps..."
        flatpak update --assumeyes

        echo "Done!"
      '')

      (writeShellScriptBin "list-chinese-apps" ''
        #!/usr/bin/env bash
        echo "Chinese apps installed via Flatpak:"
        echo ""
        ${lib.concatMapStringsSep "\n" (app: ''
          if flatpak list | grep -q "${app}"; then
            echo "✓ ${app}"
          else
            echo "✗ ${app} (not installed)"
          fi
        '') cfg.chineseApps}
      '')
    ];
  };
}
