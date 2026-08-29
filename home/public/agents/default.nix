{
  config,
  mylib,
  dotfilesDir,
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
      (t3code-desktop.override {
        t3code = t3code.override {
          providerPackages = [
            codex
            claude-code
            grok
          ];
        };
      })
    ];
    file = {
      ".codex/AGENTS.md".source = mkMutable ./codex/AGENTS.md;
      ".kimi-code/AGENTS.md".source = mkMutable ./codex/AGENTS.md;
      ".pi/agent/AGENTS.md".source = mkMutable ./pi/AGENTS.md;
      ".grok/AGENTS.md".source = mkMutable ./codex/AGENTS.md;
    };
  };
}
