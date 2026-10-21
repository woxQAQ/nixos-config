{
  lib,
  pkgs,
  ...
}:
let
  # Agent skills come from upstream repos packaged in pkg/agent-skills, so the
  # skill sources stay out of this tree. installAgentSkills lays each skill out
  # under $out/share/skills/<skill>, which we link into every agent's skill dir.
  agentSkills = pkgs.agent-skills;
  skillPath = [
    ".codex/skills"
    ".pi/agent/skills"
    ".kimi-code/skills"
    ".grok/skills"
    ".agents/skills"
    ".workbuddy-ai/skills"
    ".workbuddy/skills"
  ];
in
{
  home = {
    packages = with pkgs; [
      ast-grep
      obelisk-cli
    ];
    file = builtins.listToAttrs (
      lib.concatMap (
        target:
        map (skill: {
          name = "${target}/${skill}";
          value.source = "${agentSkills}/share/skills/agent-skills/${skill}";
        }) agentSkills.skills
      ) skillPath
    );
  };
}
