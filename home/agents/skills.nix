{
  lib,
  pkgs,
  ...
}:
let
  # Packaging includes every upstream skill; this list controls agent exposure.
  agentSkills = pkgs.agent-skills;
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
    obelisk = [ "obelisk" ];
    pstack = [
      "unslop"
      "how"
      "why"
      "bro"
    ];
  };
  selectedSkills = lib.concatLists (
    lib.mapAttrsToList (
      source:
      map (name: {
        inherit source name;
      })
    ) enabledSkills
  );
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
          value.source = "${agentSkills}/share/skills/agent-skills/${skill.source}/${skill.name}";
        }) selectedSkills
      ) skillPath
    );
  };
}
