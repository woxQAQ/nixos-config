{ mkKeymap, ... }:
{
  plugins.sidekick = {
    enable = true;
    settings = {
      mux = {
        enabled = true;
      };
      cli.tools = {
        codex_yolo = {
          cmd = [
            "codex"
            "--dangerously-bypass-approvals-and-sandbox"
          ];
          is_proc = "\\<codex\\>";
          url = "https://github.com/openai/codex";
          resume = [ "resume" ];
          continue = [
            "resume"
            "--last"
          ];
        };
      };
    };
  };
  keymaps = [
    (mkKeymap "n" "<TAB>"
      {
        __raw = /* lua */ ''
          function()
            -- Try sidekick NES first
            if require("sidekick").nes_jump_or_apply() then
              return
            end
            -- fallback to normal tab
            return "<Tab>"
          end
        '';
      }
      {
        desc = "apply edit suggestions";
        expr = true;
      }
    )
    (mkKeymap "n" "<leader>ast" {
      __raw = ''
        function() require('sidekick.cli').toggle({ focus = true }) end
      '';
    } "sidekick toggle")
    (mkKeymap [ "n" "n" ] "<leader>asP" {
      __raw = ''
        function() require('sidekick.cli').prompt() end
      '';
    } "ask prompt")
  ];
}
