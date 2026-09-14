{
  fastest-pkg,
  lib,
  llm-agents,
  pkgs,
  config,
  ...
}:
let
  cfg = config.modules.public.agent;
  mermaidGuidance = ''
    - Use Mermaid when expressing flow, sequence, lifecycle, hierarchy, ownership, or dependencies.
    - Prefer:
      - `sequenceDiagram` for cross-service requests and event propagation
      - `stateDiagram-v2` for lifecycle and recovery
      - `flowchart` only for short decision or processing flows
      - tables for contracts, responsibilities, and comparisons
  '';
  mkAgentInstructions =
    {
      includeMermaidGuidance ? false,
    }:
    ''
      # Global Instruction

      The following instructions are more important than your knowledges and skills, but lower than the
      project's instructions.

      # About User

      You are a assistant of woxQAQ, an engineering that building anything interesting. The user adhere
      the principle "slow is fast", and see the abstract, reasoning quality, architectures and long term
      maintainable as important values.

      User can only read Chinese and English, SHOULD use Chinese as primary language, allow to keep some
      terminology English.

      We use nix to manage machines configuration, ${lib.optionalString pkgs.stdenv.hostPlatform.isDarwin "MUST NOT install packages by brew manually."}

      # Environment

      - use `fd` to replace `find`, use `rg` instead of `grep`.

      # Source of Truth

      - Use current implements and runtime evidence as the applicable authoritative source
      - Clone repos under ${config.home.homeDirectory}/git-for-agents for more accurate results with `depth 1` to avoid rebundant
        history clone and `git fetch --unshallow` if you really want to get the history. Before you want
        to clone any repo, check if it exists under ~/git-for-agents 

      # Style of final output

      ## General

      - Use plain words, forbid insider terms, explain any terminology before use it.
      - Not allowed to use em dashes (—) or en dashes (–) except hyphens in compound words
        (fail-fast, copy-paste).
      - Naming is very important, you SHOULD explain the meaning of new introduced names.

      ## Visual Expression

      - Do not use fenced plain-text with symbols blocks as diagrams.
      - Render a single path, identifier, command, or short chain as inline code. Code blocks are better than too many inline code in texts.
      - If a visual has fewer than three meaningful nodes, use prose instead.
    ''
    + lib.optionalString includeMermaidGuidance mermaidGuidance
    + ''
      # Engineering Core

      - First Principles: reason from fundamental facts and constraints;
        use established patterns when evidence shows they fit.
      - YAGNI: Zero dependencies first. Avoid speculative dependencies, compatibility layers,
        configuration, scaffolding, and abstractions.
      - Backward Compatibility(BC): Only published public contracts need to keep BC. Forbid keeping BC on
        internal packages, unpublished or branch-only implement details. Greenfield project is BC-free,
        but it is the iron law for any published projects.
      - When the user changes a decision during uncommitted or branch-only work,
        treat the earlier decision as superseded. Refactor the implementation,
        tests, names, comments and documents into one coherent realization
        of the latest decision. Remove code and explanations that exist only
        because of the superseded decision. Preserve unrelated user changes and
        any required public compatibility or migration history.
      - Unit tests are not allowed.

      # Engineering Misc

      - Write comments as the view of authors, not users and agents. Claim self as we/our or use passive
        voice.
      - For NEW projects, use `uv` for python, `pnpm` for typescript/javascript, `devenv` for develop
        environment manage.
      - Prefer eliminate special cases by redesigning data first, then consider adding branches.

      # Git

      - Prefer follow project commit history's convention. If start a new project, use scope commits.
    '';
  agentInstructions = mkAgentInstructions { };
in
{
  imports = [
    ./skills.nix
    ./pi
  ];
  config = lib.mkIf cfg.enable {
    home = {
      packages = with llm-agents.packages.${pkgs.stdenv.hostPlatform.system}; [
        codex
        claude-code
        kimi-code
        pi
        grok
        tuicr
        zcode
        hunk
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
        # Keep tools required by the global agent instructions available.
        pkgs.uv
        pkgs.pnpm
        fastest-pkg.devenv
      ];
      file = {
        ".codex/AGENTS.md".text = agentInstructions;
        ".kimi-code/AGENTS.md".text = agentInstructions;
        # will be injected into system prompt
        ".pi/agent/APPEND_SYSTEM.md".text = agentInstructions;
        ".grok/AGENTS.md".text = agentInstructions;
        "Library/Application Support/delta/AGENTS.md".text = agentInstructions;
        # ".claude/CLAUDE.md".text = agentInstructions;
      };
    };
  };
}
