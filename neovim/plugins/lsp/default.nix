{
  pkgs,
  scanPlugins,
  lib,
  ...
}@args:
let
  data = scanPlugins ./. args;
  installServers = [
    "clangd"
    "nixd"
    "nushell"
    "bashls"
    "pyright"
    "lua_ls"
    "ruff"
    "helm_ls"
    "yamlls"
    "ts_ls"
    "gopls"
    "jsonls"
    "rust_analyzer"
    "cssls"
    "protols"
    "jdtls"
    "statix"
    "html"
  ];
  enableServer = builtins.listToAttrs (
    map (server: {
      name = "${server}";
      value = {
        enable = true;
      };
    }) installServers
  );

  extraSettings = {
    helm_ls.settings."helm_ls".yamlls.path = "${pkgs.yaml-language-server}/bin/yaml-language-server";
    rust_analyzer = {
      installCargo = false;
      installRustc = false;
    };
    # nixd.settings = {
    #   nixpkgs.expr = "import <nixpkgs> {}";
    #   formattings.command = [ "nixfmt" ];
    # };
    gopls.autostart = true;
    bashls.settings.filetypes = [
      "sh"
      "zsh"
    ];
    lua_ls.settings.diagnostics = {
      disable = [ "miss-name" ];
      globals = [
        "vim"
        "cmp"
      ];
    };
    yamlls.extraOptions.yaml.schames = {
      kubernetes = [
        "k8s/**/*.{yml,yaml}"
        "kubernetes/**/*.{yml,yaml}"
        "manifests/**/*.{yml,yaml}"
        "**/k8s/**/*.{yml,yaml}"
        "**/kubernetes/**/*.{yml,yaml}"
        "**/manifests/**/*.{yml,yaml}"
        "*deployment*.{yml,yaml}"
        "*service*.{yml,yaml}"
        "*configmap*.{yml,yaml}"
        "*secret*.{yml,yaml}"
        "*ingress*.{yml,yaml}"
        "*pod*.{yml,yaml}"
        "*namespace*.{yml,yaml}"
      ];
      "http://json.schemastore.org/github-workflow" = ".github/workflows/*";
      "http://json.schemastore.org/github-action" = ".github/action.{yml,yaml}";
      "http://json.schemastore.org/ansible-stable-2.9" = "roles/tasks/*.{yml,yaml}";
      "http://json.schemastore.org/kustomization" = "kustomization.{yml,yaml}";
      "http://json.schemastore.org/ansible-playbook" = "*play*.{yml,yaml}";
      "http://json.schemastore.org/chart" = "Chart.{yml,yaml}";
      "https://json.schemastore.org/dependabot-v2" = ".github/dependabot.{yml,yaml}";
      "https://raw.githubusercontent.com/compose-spec/compose-spec/master/schema/compose-spec.json" =
        "*docker-compose*.{yml,yaml}";
      "https://raw.githubusercontent.com/argoproj/argo-workflows/master/api/jsonschema/schema.json" =
        "*flow*.{yml,yaml}";
    };
  };
in
lib.attrsets.mergeAttrsList [
  (lib.attrsets.mergeAttrsList data)
  {
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

    # ts-autotag = {
    #   enable = true;
    # };

    lsp = {
      enable = true;
      inlayHints = true;
      servers = enableServer // extraSettings;
      keymaps = {
        silent = true;
        lspBuf = {
          gD = "references";
        };

        extra = [
          {
            action = "<CMD>Lspsaga code_action<CR>";
            key = "<leader>ca";
            options.desc = "code action";
          }
          {
            action = "<CMD>Lspsaga rename<CR>";
            key = "<leader>cr";
            options.desc = "rename";
          }
          {
            action = "<CMD>Lspsaga finder<CR>";
            key = "gr";
            options.desc = "find references";
          }
          {
            action = "<CMD>Lspsaga finder imp<CR>";
            key = "gi";
            options.desc = "find implement";
          }
          {
            action = "<CMD>Lspsaga peek_definition<CR>";
            key = "gd";
            options.desc = "find definition";
          }
          {
            action = "<CMD>Lspsaga peek_type_definition<CR>";
            key = "gt";
            options.desc = "find type definition";
          }
          {
            action = "<CMD>Lspsaga hover_doc<CR>";
            key = "K";
            options.desc = "hover doc";
          }
        ];
      };
    };
  }
]
