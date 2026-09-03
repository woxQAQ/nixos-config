{
  fastest-pkg,
  lib,
  llm-agents,
  pkgs,
  ...
}:
let
  mermaidGuidance = ''
    - Mermaid diagram better than plain text. Prefer several simple mermaids rather than an all-in-one mermaid.
    - Flowchart/graph is common-used chart, but it will cause spaghetti problem, you should try other mermaid
      charts such as timeline, stateDiagram-v2,sequenceDiagram and mindmap as much as possible.
  '';
  mkAgentInstructions =
    {
      includeMermaidGuidance ? true,
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

      We use nix to manage all hosts configuration, MUST NOT install packages by well-known package
      managers such as brew. Use `devenv` to setup a environment if really needed.

      # Environment

      - use `fd` to replace `find`, use `rg` instead of `grep`.

      # Source of Truth

      - Documents, history, memory and former conclusion as leads. Use current implements and runtime
        evidence as the applicable authoritative source

      # Style

      - Be terse/brief. Skip preamble, filler phrases, and summaries.
      - Be skeptical about user requests, do NOT follow everything the user wants, first do an
        assessment if the implementation does really make sense, and whether it fits the scope of the project
    ''
    + lib.optionalString includeMermaidGuidance mermaidGuidance
    + ''
      - Use plain words, forbid insider terms, or explain any terminology before use it.
      - Give your examples(data shape, code snippets) rather than long plain text, reference
        the content with appropriate comments other than the line number.
      - Conversational, not dramatic. Use contractions ("so/but" not "therefore/however").
        No scaffolding ("it is worth noting"), no hype adjectives ("brutally", "killer feature"),
        no setup phrases ("here's the thing"). No "not just X, but Y".
      - Not allowed to use em dashes (—) or en dashes (–) except hyphens in compound words
        (fail-fast, copy-paste).

      # Engineering Core

      - First Principles: reason from fundamental facts and constraints;
        use established patterns when evidence shows they fit.
      - YAGNI: Zero dependencies first. Avoid speculative dependencies, compatibility layers,
        configuration, scaffolding, and abstractions.
      - Backward Compatibility(BC): Only public contract need to keep BC. Forbid keeping BC on
        internal packages, unpublished or branch-only implement details. Greenfield project is BC-free,
        but it is the iron law for any published projects.
      - When the user changes a decision during uncommitted or branch-only work,
        treat the earlier decision as superseded. Refactor the implementation,
        tests, names, comments, and documentation into one coherent realization
        of the latest decision. Remove code and explanations that exist only
        because of the superseded decision. Preserve unrelated user changes and
        any required public compatibility or migration history.
      - After completing a design or implementation, conduct ablation experiments to remove unnecessary
        abstractions and design elements.

      # Engineering Misc

      - Write comments as the view of authors, not users and agents. Claim self as we/our or use passive
        voice.
      - For new projects, use `uv` for python, `pnpm` for typescript/javascript, `devenv` for develop
        environment manage.
      - Name is very important, you should explain the name.
      - Prefer eliminate special cases by redesigning data first, and then adding branches

      # Git

      - Prefer follow project commit history's convention. If start a new project, use scope commits.
    '';
  agentInstructions = mkAgentInstructions { };
  kimiCodeInstructions = mkAgentInstructions { includeMermaidGuidance = false; };
in
{
  imports = [
    ./skills.nix
    ./pi
  ];

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
      # Keep tools required by the global agent instructions available.
      pkgs.uv
      pkgs.pnpm
      fastest-pkg.devenv
    ];
    file = {
      ".codex/AGENTS.md".text = agentInstructions;
      # kimi code donot support mermaid render
      ".kimi-code/AGENTS.md".text = kimiCodeInstructions;
      # will be injected into system prompt
      ".pi/agent/APPEND_SYSTEM.md".text = agentInstructions;
      ".grok/AGENTS.md".text = agentInstructions;
      # ".claude/CLAUDE.md".text = agentInstructions;
    };
  };
}
