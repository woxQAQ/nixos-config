{
  fastest-pkg,
  lib,
  llm-agents,
  pkgs,
  config,
  username,
  ...
}:
let
  cfg = config.modules.agents;
  mkAgentInstructions =
    {
      includeBashEditGuideance ? false,
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

      - bash preference: use `fd` to replace `find`, use `rg` instead of `grep`.${lib.optionalString includeBashEditGuideance " Do not edit files by bash scripts."}
      - We use nix to manage machines configuration${lib.optionalString pkgs.stdenv.hostPlatform.isDarwin ", MUST NOT install packages by brew manually."}

      # Source of Truth

      - Use current implements and runtime evidence as the applicable authoritative source
      - Clone repos under ${config.home.homeDirectory}/git-for-agents for more accurate results with `--depth 1` to reduce 
        history clone and `git fetch --unshallow` if you really want rest history.
        Before you clone any repo, check if it exists.

      # Style

      - You SHOULD explain new introduced names.
      - Avoid false dichotomies and over-binarization. Don't habitually use “not X but Y”
        constructions. Preserve nuance, ambiguity, gradation, multiple causality, and overlapping explanations.
        Do not reify contextual or conceptual distinctions into rigid oppositions.
      - Use pseudocode in javascript or mermaid diagrams to describe complex logic.

      # Engineering Core

      - reason from fundamental facts and constraints;
        use established patterns when evidence shows they fit.
      - Zero dependencies first. Avoid speculative dependencies, compatibility layers,
        configuration, scaffolding, and abstractions.
      - Backward Compatibility(BC): Only published public contracts need to keep BC. Forbid keeping BC on
        internal packages, unpublished or branch-only implement details.
      - Unit tests are not allowed.

      # Engineering Misc

      - Write comments as the view of authors, not users and agents. Claim self as we/our or use passive voice.
      - For NEW projects, use `uv` for python, `pnpm` for typescript/javascript, `devenv` for develop environment manage.
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
  ];
  home = {
    # minimal 覆盖日常编码工作流：核心 CLI agent 加上全局指令依赖的工具链；
    # full 在此基础上追加备选 agent、review 工具与桌面应用
    packages =
      (with llm-agents.packages.${pkgs.stdenv.hostPlatform.system}; [
        pi
      ])
      ++ [
        # Keep tools required by the global agent instructions available.
        pkgs.uv
        pkgs.pnpm
        fastest-pkg.devenv
      ]
      ++ lib.optionals (cfg.profile == "terminal") (
        with llm-agents.packages.${pkgs.stdenv.hostPlatform.system};
        [
          codex
          kimi-code
          tuicr
        ]
      )
      ++ lib.optionals (cfg.profile == "full") (
        with llm-agents.packages.${pkgs.stdenv.hostPlatform.system};
        [
          grok
          claude-code
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
        ]
      );
    file = {
      ".codex/AGENTS.md".text = mkAgentInstructions { includeBashEditGuideance = true; };
      ".kimi-code/AGENTS.md".text = mkAgentInstructions { };
      # will be injected into system prompt
      ".pi/agent/APPEND_SYSTEM.md".text = defaultInstructions;
      ".grok/AGENTS.md".text = defaultInstructions;
      "Library/Application Support/delta/AGENTS.md".text = defaultInstructions;
      # ".claude/CLAUDE.md".text = agentInstructions;
    };
  };
}
