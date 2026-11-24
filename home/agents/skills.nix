{
  lib,
  pkgs,
  config,
  ...
}:
let
  # Packaging includes every upstream skill; this list controls agent exposure.
  neuve = config.modules.agents.neuve;
  agentSkills = pkgs.agent-skills.override {
    neuve = if neuve.enable && neuve.skills.enable then neuve.package else null;
  };
  enabledSkills = {
    anthropic = [ "frontend-design" ];
    ast-grep = [
      "ast-grep"
      "ast-grep-outline"
    ];
    i-have-adhd = [ "i-have-adhd" ];
    improve = [ "improve" ];
    kill-ai-slop = [ "kill-ai-slop" ];
    mattpocock = [
      "grill-me"
      # grill-me delegates to grilling.
      "grilling"
      "handoff"
      "research"
      "teach"
      "writing-for-agents"
    ];
    pstack = [
      "unslop"
      "how"
      "why"
      "bro"
    ];
  }
  // lib.optionalAttrs (neuve.enable && neuve.skills.enable) {
    neuve = [ "neuve" ];
  };
  selectedSkills =
    lib.concatLists (
      lib.mapAttrsToList (
        source:
        map (name: {
          inherit name;
          path = "${agentSkills}/share/skills/agent-skills/${source}/${name}";
        })
      ) enabledSkills
    )
    ++ [
      # The skill ships with the CLI it documents.
      {
        name = "obelisk";
        path = "${pkgs.obelisk-cli}/share/skills/obelisk";
      }
    ];
  skillNames = map (skill: skill.name) selectedSkills;
  skillPath = [
    ".codex/skills"
    ".pi/agent/skills"
    ".grok/skills"
    ".agents/skills"
    ".claude/skills"
  ];
in
{
  assertions = [
    {
      assertion =
        builtins.length skillNames == builtins.length (lib.unique skillNames);
      message = "Agent skills selected from different sources must have unique names.";
    }
  ];

  home = {
    packages = with pkgs; [
      ast-grep
      obelisk-cli
    ];
    file = builtins.listToAttrs (
      lib.concatMap (
        target:
        map (skill: {
          name = "${target}/${skill.name}";
          value.source = skill.path;
        }) selectedSkills
      ) skillPath
    );
  };
}
