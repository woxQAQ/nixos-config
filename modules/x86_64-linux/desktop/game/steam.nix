{
  pkgs,
  config,
  lib,
  # aagl,
  ...
}:
with lib;
let
  cfg = config.modules.desktop.game;
in
{
  config = mkIf cfg.enable {
    boot.kernel.sysctl = {
      "kernel.sched_cfs_bandwidth_slice_us" = 3000;
      "net.ipv4.tcp_fin_timeout" = 5;
      "kernel.split_lock_mitigate" = 0;
      "vm.max_map_count" = 2147483642;
    };
    environment.variables.UMU_PROTONPATH = "${pkgs.dwproton-bin.steamcompattool}";
    programs = {
      gamemode = {
        enable = true;
      };
      steam = {
        enable = true;
        dedicatedServer.openFirewall = false;
        protontricks.enable = true;
        extest.enable = true;
        fontPackages = [ pkgs.wqy_zenhei ];
        extraCompatPackages = [
          pkgs.proton-ge-bin
          pkgs.dwproton-bin
        ];
      };

    };

    services = {
      pipewire = {
        extraConfig = {
          pipewire."99-lowlatency" = {
            "context.properties"."default.clock.min-quantum" = 64;
            "context.modules" = [
              {
                name = "libpipewire-module-rt";
                flags = [
                  "ifexists"
                  "nofail"
                ];
                args = {
                  "nice.level" = -15;
                  "rt.prio" = 88;
                  "rt.time.soft" = 200000;
                  "rt.time.hard" = 200000;
                };
              }
            ];
          };

          pipewire-pulse."99-lowlatency"."pulse.properties" = {
            "server.address" = [ "unix:native" ];
            "pulse.min.req" = "64/48000";
            "pulse.min.quantum" = "64/48000";
            "pulse.min.frag" = "64/48000";
          };
          client."99-lowlatency"."stream.properties" = {
            "node.latency" = "64/48000";
            "resample.quality" = 1;
          };
        };
      };
    };

    environment.systemPackages = with pkgs; [
      mangohud
      gst_all_1.gstreamer
    ];
  };
}
