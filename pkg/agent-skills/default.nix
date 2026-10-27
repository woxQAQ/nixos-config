{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  installAgentSkills,
}:
let
  anthropicSkills = fetchFromGitHub {
    owner = "anthropics";
    repo = "skills";
    rev = "dbd4588f9e1033efb41dad4bef2f7947c8993d44";
    hash = "sha256-+UIqBnzyeIOvJSKYaDaE3GYPEpLw7qQqyUw5S971AfU=";
  };

  # Upstream layouts do not always match the skill name in SKILL.md frontmatter
  # (e.g. ast-grep ships `skills/outline` for the `ast-grep-outline` skill), so
  # the install phase stages each skill under its published name.
  astGrep = fetchFromGitHub {
    owner = "ast-grep";
    repo = "agent-skill";
    rev = "f2175aff21f20cfb8e2db30c28febeb3a2d42b61";
    hash = "sha256-dORqiMdFOUQVEF6wn1IZiTIcslzO+441A0GZP4KNcOQ=";
  };

  iHaveAdhd = fetchFromGitHub {
    owner = "ayghri";
    repo = "i-have-adhd";
    rev = "1ecea1993b7fce257ffbd686c070948b5e07eda6";
    hash = "sha256-GTqrnZxQvzo/ogAuUrffkOaMK1BYm/4rAZsnfmDt7DU=";
  };

  killAiSlop = fetchFromGitHub {
    owner = "yetone";
    repo = "kill-ai-slop";
    rev = "f6e2ae32b30443ec7bd0da4da971ee18d8f8ffcb";
    hash = "sha256-5kUlXiBbbpwj6UT2VhFIW7f9EFo3iWT0UKWl41PGbQA=";
  };

  mattPocockSkills = fetchFromGitHub {
    owner = "mattpocock";
    repo = "skills";
    rev = "5beb35b040e3de97e54fa9e386d7e42d15c295c2";
    hash = "sha256-2FKfe3/Fwc4MmwBLa+d/oQW4/gtYIssdWapy2MPd39I=";
  };

  obelisk = fetchFromGitHub {
    owner = "tommy0103";
    repo = "obelisk-skill";
    rev = "e883398c3d61ff6715e43ed8092d033df6ef8880";
    hash = "sha256-2un/eGLVp5ejq1HuimEm0xKWSs3ximBxfEd69MsM62U=";
  };

  pstack = fetchFromGitHub {
    owner = "backnotprop";
    repo = "pstack";
    rev = "18b6c36e6e201b110acc62472de987416ac4e23b";
    hash = "sha256-hsGfW8S58TL5QPv9VbhQ5/V1JyPhz52y4we914LELOI=";
  };
in
stdenvNoCC.mkDerivation {
  pname = "agent-skills";
  version = "0-unstable-2026-10-25";

  dontUnpack = true;

  nativeBuildInputs = [ installAgentSkills ];

  installPhase = ''
    runHook preInstall

    mkdir -p staged
    cp -R ${astGrep}/ast-grep/skills/ast-grep staged/ast-grep
    cp -R ${astGrep}/ast-grep/skills/outline staged/ast-grep-outline

    cp -R ${anthropicSkills}/skills/frontend-design staged/frontend-design
    cp -R ${mattPocockSkills}/skills/productivity/grill-me staged/grill-me
    # grill-me delegates to the grilling skill.
    cp -R ${mattPocockSkills}/skills/productivity/grilling staged/grilling
    cp -R ${mattPocockSkills}/skills/productivity/handoff staged/handoff
    cp -R ${mattPocockSkills}/skills/engineering/research staged/research
    cp -R ${mattPocockSkills}/skills/productivity/teach staged/teach

    # pstack
    cp -R ${pstack}/skills/unslop staged/unslop
    cp -R ${pstack}/skills/arena staged/arena
    cp -R ${pstack}/skills/how staged/how
    cp -R ${pstack}/skills/why staged/why
    cp -R ${pstack}/skills/architect staged/architect

    cp -R ${obelisk}/skills/obelisk staged/obelisk

    cp -R ${iHaveAdhd}/skills/i-have-adhd staged/i-have-adhd
    cp -R ${killAiSlop}/skill staged/kill-ai-slop

    for skill in staged/*; do
      installSkill "$skill"
    done

    runHook postInstall
  '';

  passthru.skills = [
    "ast-grep"
    "ast-grep-outline"
    "frontend-design"
    "grill-me"
    "grilling"
    "handoff"
    "research"
    "teach"
    "unslop"
    "arena"
    "how"
    "why"
    "architect"
    "obelisk"
    "i-have-adhd"
    "kill-ai-slop"
  ];

  meta = {
    description = "Agent skills for code analysis, design, writing, research, learning, and session management";
    license = with lib.licenses; [
      asl20
      mit
    ];
    platforms = lib.platforms.all;
  };
}
