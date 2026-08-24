{
  programs.aerospace = {
    enable = true;
    launchd.enable = true;

    settings = {
      "after-startup-command" = [
        "exec-and-forget borders active_color=0xffe1e3e4 inactive_color=0xff494d64 width=5.0"
      ];

      "enable-normalization-flatten-containers" = true;
      "enable-normalization-opposite-orientation-for-nested-containers" = true;

      "accordion-padding" = 30;
      "default-root-container-layout" = "tiles";
      "default-root-container-orientation" = "auto";
      "on-focused-monitor-changed" = [ "move-mouse monitor-lazy-center" ];

      "automatically-unhide-macos-hidden-apps" = false;

      "key-mapping".preset = "qwerty";

      gaps = {
        inner = {
          horizontal = 3;
          vertical = 3;
        };
        outer = {
          left = 3;
          bottom = 3;
          top = 3;
          right = 3;
        };
      };

      exec = {
        "inherit-env-vars" = true;
        "env-vars".PATH = "/opt/homebrew/bin:/opt/homebrew/sbin:\${PATH}";
      };

      mode = {
        main.binding = {
          "alt-slash" = "layout tiles horizontal vertical";
          "alt-comma" = "layout accordion horizontal vertical";

          # Use an explicit app path instead of AppleScript `activate`:
          # LaunchServices may resolve "kitty" by name to a stale nix-store registration
          # from a previous generation, which AeroSpace fails to manage.
          "alt-enter" = "exec-and-forget open \"$HOME/Applications/Home Manager Apps/kitty.app\"";
          "alt-n" = "exec-and-forget osascript -e 'tell application \"notion\" to activate'";
          "alt-o" = "exec-and-forget osascript -e 'tell application \"obsidian\" to activate'";
          "alt-z" = "exec-and-forget osascript -e 'tell application \"zed\" to activate'";
          "alt-c" = "exec-and-forget osascript -e 'tell application \"chatgpt\" to activate'";
          "alt-a" = "exec-and-forget osascript -e 'tell application \"dia\" to activate'";

          "alt-h" = "focus left";
          "alt-j" = "focus down";
          "alt-k" = "focus up";
          "alt-l" = "focus right";

          "alt-shift-h" = "move left";
          "alt-shift-j" = "move down";
          "alt-shift-k" = "move up";
          "alt-shift-l" = "move right";

          "alt-shift-minus" = "resize smart -50";
          "alt-shift-equal" = "resize smart +50";

          "alt-1" = "workspace 1Terminal";
          "alt-2" = "workspace 2Browser";
          "alt-3" = "workspace 3Code";
          "alt-4" = "workspace 4Work";
          "alt-5" = "workspace 5Folo";
          "alt-6" = "workspace 6Chat";
          "alt-7" = "workspace 7Music";
          "alt-8" = "workspace 8Mail";
          "alt-9" = "workspace 9Float";
          "alt-0" = "workspace 0Obsidian";

          "alt-shift-1" = "move-node-to-workspace 1Terminal";
          "alt-shift-2" = "move-node-to-workspace 2Browser";
          "alt-shift-3" = "move-node-to-workspace 3Code";
          "alt-shift-4" = "move-node-to-workspace 4Work";
          "alt-shift-5" = "move-node-to-workspace 5Folo";
          "alt-shift-6" = "move-node-to-workspace 6Chat";
          "alt-shift-7" = "move-node-to-workspace 7Music";
          "alt-shift-8" = "move-node-to-workspace 8Mail";
          "alt-shift-9" = [
            "layout floating"
            "move-node-to-workspace 9Float"
          ];
          "alt-shift-0" = "move-node-to-workspace 0Obsidian";
          "alt-tab" = "workspace-back-and-forth";
          "alt-shift-tab" = "move-workspace-to-monitor --wrap-around next";

          "alt-shift-semicolon" = "mode service";
          "alt-r" = "mode resize";
        };

        resize.binding = {
          h = "resize width +50";
          j = "resize height +50";
          k = "resize height -50";
          l = "resize width -50";
          enter = "mode main";
          esc = "mode main";
        };

        service.binding = {
          esc = [
            "reload-config"
            "mode main"
          ];
          r = [
            "flatten-workspace-tree"
            "mode main"
          ];
          f = [
            "layout floating tiling"
            "mode main"
          ];
          backspace = [
            "close-all-windows-but-current"
            "mode main"
          ];

          "alt-shift-h" = [
            "join-with left"
            "mode main"
          ];
          "alt-shift-j" = [
            "join-with down"
            "mode main"
          ];
          "alt-shift-k" = [
            "join-with up"
            "mode main"
          ];
          "alt-shift-l" = [
            "join-with right"
            "mode main"
          ];
        };
      };

      "on-window-detected" = [
        {
          "if"."app-id" = "net.kovidgoyal.kitty";
          run = "move-node-to-workspace 1Terminal";
        }
        {
          "if"."app-id" = "company.thebrowser.dia";
          run = "move-node-to-workspace 2Browser";
        }
        {
          "if"."app-id" = "dev.zed.Zed";
          run = "move-node-to-workspace 3Code";
        }
        {
          "if"."app-id" = "com.todesktop.230313mzl4w4u92";
          run = "move-node-to-workspace 3Code";
        }
        {
          "if"."app-id" = "com.apple.mail";
          run = "move-node-to-workspace 8Mail";
        }
        {
          "if"."app-id" = "com.apple.iCal";
          run = "move-node-to-workspace 8Mail";
        }
        {
          "if"."app-id" = "com.coteditor.CotEditor";
          run = [ "layout floating" ];
        }
        {
          "if"."app-id" = "com.apple.finder";
          run = [
            "layout floating"
            "move-node-to-workspace 9Float"
          ];
        }
        {
          "if"."app-id" = "com.apple.systempreferences";
          run = [
            "layout floating"
            "move-node-to-workspace 9Float"
          ];
        }
        {
          "if"."app-id" = "com.apple.freeform";
          run = [
            "layout floating"
            "move-node-to-workspace 9Float"
          ];
        }
        {
          "if"."app-id" = "com.netease.163music";
          run = "move-node-to-workspace 7Music";
        }
        {
          "if"."app-id" = "com.tencent.xinWeChat";
          run = "move-node-to-workspace 6Chat";
        }
        {
          "if"."app-id" = "com.tencent.qq";
          run = "move-node-to-workspace 6Chat";
        }
        {
          "if"."app-id" = "com.electron.lark";
          run = "move-node-to-workspace 4Work";
        }
        {
          "if"."app-id" = "is.follow";
          run = "move-node-to-workspace 5Folo";
        }
        {
          "if"."app-id" = "md.obsidian";
          run = "move-node-to-workspace 0Obsidian";
        }
        {
          "if"."app-id" = "com.colliderli.iina";
          run = "layout floating";
        }
        {
          "if"."app-id" = "com.jd.jdmeeting";
          run = "layout floating";
        }
      ];
    };
  };
}
