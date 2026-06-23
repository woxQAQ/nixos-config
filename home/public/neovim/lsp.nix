{
  lsp.servers = {
    copilot.enable = true;
    nixd.enable = true;
    gopls.enable = true;
    bashls.enable = true;
    ts_ls.enable = true;
    rust_analyzer = {
      enable = false;
      config.settings = {
        cargo = {
          buildScripts.enable = true;
          features = "all";
        };
        checkOnSave = true;
        check = {
          command = "clippy";
          features = "all";
        };
        files = {
          excludeDirs = [
            ".direnv"
            "rust/.direnv"
          ];
        };

        inlayHints = {
          bindingModeHints.enable = true;
          closureStyle = "rust_analyzer";
          closureReturnTypeHints.enable = "always";
          discriminantHints.enable = "always";
          expressionAdjustmentHints.enable = "always";
          implicitDrops.enable = true;
          lifetimeElisionHints.enable = "always";
          rangeExclusiveHints.enable = true;
        };

        procMacro = {
          enable = true;
        };

        rustc.source = "discover";
      };
    };
    biome = {
      enable = true;
    };
  };
}
