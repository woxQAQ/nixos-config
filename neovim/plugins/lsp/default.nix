{pkgs, ...}: {
  imports = [
    ./keymaps.nix
    ./lspsaga.nix
    ./refactor.nix
    ./fidget.nix
  ];

  programs.nixvim = {
    plugins = {
      lsp-format = {
        enable = true;
        lspServersToEnable = "all";
      };
      nix = {
        enable = true;
      };

      colorizer = {
        enable = true;
        settings.user_default_options.css = true;
      };

      ts-autotag = {
        enable = true;
      };

      lsp = {
        enable = true;
        inlayHints = true;
        servers = {
          clangd.enable = true;
          nil_ls = {
            enable = true;
            settings.formatting.command = [
              "alejandra"
            ];
          };
          pylsp.enable = true;
          pyright = {
            enable = true;
          };

          helm_ls = {
            enable = true;
            extraOptions = {
              settings = {
                "helm_ls" = {
                  yamlls = {
                    path = "${pkgs.yaml-language-server}/bin/yaml-language-server";
                  };
                };
              };
            };
          };

          ts_ls = {
            enable = true;
            settings.formatting.command = [
              "prettier"
            ];
          };
          cssls = {
            enable = true;
            filetypes = ["css" "scss" "less"];
          };
          protols.enable = true;
          html.enable = true;
          statix.enable = true;
          rust_analyzer = {
            enable = true;
            installCargo = false;
            installRustc = false;
          };
          jsonls.enable = true;
          gopls = {
            enable = true;
            autostart = true;
          };
          yamlls = {
            enable = true;
            extraOptions = {
              settings = {
                yaml = {
                  schemas = {
                    kubernetes = "'*.yaml";
                    "http://json.schemastore.org/github-workflow" = ".github/workflows/*";
                    "http://json.schemastore.org/github-action" = ".github/action.{yml,yaml}";
                    "http://json.schemastore.org/ansible-stable-2.9" = "roles/tasks/*.{yml,yaml}";
                    "http://json.schemastore.org/kustomization" = "kustomization.{yml,yaml}";
                    "http://json.schemastore.org/ansible-playbook" = "*play*.{yml,yaml}";
                    "http://json.schemastore.org/chart" = "Chart.{yml,yaml}";
                    "https://json.schemastore.org/dependabot-v2" = ".github/dependabot.{yml,yaml}";
                    "https://raw.githubusercontent.com/compose-spec/compose-spec/master/schema/compose-spec.json" = "*docker-compose*.{yml,yaml}";
                    "https://raw.githubusercontent.com/argoproj/argo-workflows/master/api/jsonschema/schema.json" = "*flow*.{yml,yaml}";
                  };
                };
              };
            };
          };
        };
      };
    };
  };
}
