{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  installAgentSkills,
}:
let
  # Upstream layouts do not always match the skill name in SKILL.md frontmatter
  # (e.g. ast-grep ships `skills/outline` for the `ast-grep-outline` skill), so
  # the install phase stages each skill under its published name.
  astGrep = fetchFromGitHub {
    owner = "ast-grep";
    repo = "agent-skill";
    rev = "f2175aff21f20cfb8e2db30c28febeb3a2d42b61";
    hash = "sha256-dORqiMdFOUQVEF6wn1IZiTIcslzO+441A0GZP4KNcOQ=";
  };

  killAiSlop = fetchFromGitHub {
    owner = "yetone";
    repo = "kill-ai-slop";
    rev = "f6e2ae32b30443ec7bd0da4da971ee18d8f8ffcb";
    hash = "sha256-5kUlXiBbbpwj6UT2VhFIW7f9EFo3iWT0UKWl41PGbQA=";
  };

  obelisk = fetchFromGitHub {
    owner = "tommy0103";
    repo = "obelisk-skill";
    rev = "e883398c3d61ff6715e43ed8092d033df6ef8880";
    hash = "sha256-2un/eGLVp5ejq1HuimEm0xKWSs3ximBxfEd69MsM62U=";
  };
in
stdenvNoCC.mkDerivation {
  pname = "agent-skills";
  version = "0-unstable-2026-10-22";

  dontUnpack = true;

  nativeBuildInputs = [ installAgentSkills ];

  installPhase = ''
    runHook preInstall

    mkdir -p staged
    cp -R ${astGrep}/ast-grep/skills/ast-grep staged/ast-grep
    cp -R ${astGrep}/ast-grep/skills/outline staged/ast-grep-outline
    cp -R ${killAiSlop}/skill staged/kill-ai-slop
    cp -R ${obelisk}/skills/obelisk staged/obelisk

    for skill in staged/*; do
      installSkill "$skill"
    done

    runHook postInstall
  '';

  passthru.skills = [
    "ast-grep"
    "ast-grep-outline"
    "kill-ai-slop"
    "obelisk"
  ];

  meta = {
    description = "Agent skills for ast-grep, de-slopping web UIs, and session history retrieval";
    license = lib.licenses.mit;
    platforms = lib.platforms.all;
  };
}
