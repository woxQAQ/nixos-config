{
  lib,
  llm-agents,
  pkgs,
  config,
  username,
  dotfilesDir,
  ...
}:
let
  cfg = config.modules.agents;
  agents = llm-agents.packages.${pkgs.stdenv.hostPlatform.system};
  agentNames = [
    "pi"
  ]
  ++ lib.optionals (cfg.profile == "terminal") [
    "grok"
    "codex"
    "kimi-code"
    "claude-code"
    "tuicr"
  ];
  providerNames = [
    "codex"
    "claude-code"
    "grok"
    "pi"
  ];
  monitoredAgents = lib.genAttrs (lib.unique (
    agentNames
    ++ lib.optionals (cfg.profile == "full") ([ "t3code" ] ++ providerNames)
  )) (name: agents.${name});
  mkAgentInstructions =
    {
      includeBashEditGuideance ? true,
      codemode ? false,
    }:
    ''
      # Global Instruction

      The following instructions are more important than your knowledges and skills, but lower than the
      project's instructions.

      # About User

      You are a assistant of ${username}, a backend engineer. The user adhere "slow is fast"
      and see abstract, reasoning quality, architectures and long term maintainable as important values.

      User can only read Chinese and English, SHOULD use Chinese as primary language, allow to keep some
      terminology English.

      # Environment

      - Shell preference: use `fd` to replace `find`, use `rg` instead of `grep`.${lib.optionalString includeBashEditGuideance " Do not edit files by bash tools."}
      - We use nix to manage machines configuration${lib.optionalString pkgs.stdenv.hostPlatform.isDarwin ", MUST NOT install packages by brew manually."}
      - ${dotfilesDir} contains the system nixos configuration so any patches to the system should apply to this repo.

      # Source of Truth

      - Use current implements and runtime evidence as the applicable authoritative source
      - Clone repos under ${config.home.homeDirectory}/git-for-agents for more accurate results with `--depth 1` to reduce 
        history clone and `git fetch --unshallow` if you really want rest history.
        Before you clone any repo, check if it exists.

      # Style

      - You SHOULD explain new introduced names.
      - Use mermaid diagrams to describe complex logic.

      ${lib.optionalString codemode ''
        # Code Mode
          When using codemode, write readable, multiline JavaScript.

          Prefer plain javascript codes for hard logic than inline script in bash tool.
      ''}
      # Engineering Core

      - reason from fundamental facts and constraints;
        use established patterns when evidence shows they fit.
      - Zero dependencies first. That doesn't mean you should vendor any ability. 
      - Backward Compatibility(BC): Only published public contracts need to keep BC. Forbid keeping BC on
        internal packages, unpublished or branch-only implement details.
      - Tests are software too, need to be designed. And unit tests to functions are not allowed. 

      # Engineering Misc

      - Write comments as the view of authors, not users and agents. Claim self as we/our or use passive voice.
      - For NEW projects, use `uv` for python, `pnpm` for typescript/javascript.
      - Prefer eliminate special cases by redesigning data struct first, then consider adding code paths.
      - Follow project commit history's convention. Use scoped commits for new projects.
    '';
  defaultInstructions = mkAgentInstructions { };
in
{
  imports = [
    ./skills.nix
    ./options.nix
    ./pi
    (import ./update-notifier { packages = monitoredAgents; })
  ];
  home = {
    # Each profile's package list also supplies the activated version manifest.
    packages =
      (map (name: agents.${name}) agentNames)
      ++ [
        # Keep tools required by the global agent instructions available.
        pkgs.uv
        pkgs.pnpm
        pkgs.devenv
      ]
      ++ lib.optionals (cfg.profile == "full") [
        # Include the selected providers in both t3code and the update checks.
        (agents.t3code-desktop.override {
          t3code = agents.t3code.override {
            providerPackages = map (name: agents.${name}) providerNames;
          };
        })
      ];
    file = {
      ".codex/AGENTS.md".text = mkAgentInstructions {
        includeBashEditGuideance = true;
      };
      ".kimi-code/AGENTS.md".text = mkAgentInstructions { };
      # will be injected into system prompt
      ".pi/agent/APPEND_SYSTEM.md".text = mkAgentInstructions { codemode = true; };
      ".grok/AGENTS.md".text = defaultInstructions;
      "Library/Application Support/delta/AGENTS.md".text = defaultInstructions;
      # ".claude/CLAUDE.md".text = agentInstructions;
    };
  };
}
