{ lib, pkgs, ... }:
let
  skillPath = [
    ".codex/skills"
    ".pi/agent/skills"
    ".kimi-code/skills"
    ".grok/skills"
    ".agents/skills"
  ];
  skillDir = ./.agents/skills;
  skills = builtins.attrNames (
    lib.attrsets.filterAttrs (_: type: type == "directory") (builtins.readDir skillDir)
  );
in
{
  home = {
    packages = with pkgs; [
      ast-grep
    ];
    file = builtins.listToAttrs (
      lib.concatMap (
        target:
        map (skill: {
          name = "${target}/${skill}";
          value.source = skillDir + "/${skill}";
        }) skills
      ) skillPath
    );
  };
}
