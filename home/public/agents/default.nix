{
  config,
  mylib,
  dotfilesDir,
  fastest-pkg,
  llm-agents,
  pkgs,
  ...
}:
let
  mkMutable = mylib.mkMutable dotfilesDir config;
in
{
  imports = [ ./skills.nix ];

  home = {
    packages = with llm-agents.packages.${pkgs.stdenv.hostPlatform.system}; [
      bb-app
      codex
      claude-code
      kimi-code
      pi
      grok
      tuicr
      # upstream llm-agents bundled the opencode and cursor agent into t3code
      # by default. They also provide the providerPackages override in t3code package that
      # can choose the agent we use.
      #
      # see https://github.com/numtide/llm-agents.nix/blob/main/packages/t3code/package.nix
      (t3code-desktop.override {
        t3code = t3code.override {
          providerPackages = [
            codex
            claude-code
            grok
          ];
        };
      })
      # package mentioned in the ./AGENTS.md, should keep it exists in this module
      pkgs.uv
      pkgs.pnpm
      fastest-pkg.devenv
    ];
    file = {
      ".codex/AGENTS.md".source = mkMutable ./AGENTS.md;
      ".kimi-code/AGENTS.md".source = mkMutable ./AGENTS.md;
      # will be injected into system prompt
      ".pi/agent/APPEND_SYSTEM.md".source = mkMutable ./AGENTS.md;
      ".grok/AGENTS.md".source = mkMutable ./AGENTS.md;
      ".claude/CLAUDE.md".source = mkMutable ./AGENTS.md;
    };
  };
}
