{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  python3,
}:
let
  anthropicSkills = fetchFromGitHub {
    owner = "anthropics";
    repo = "skills";
    rev = "dbd4588f9e1033efb41dad4bef2f7947c8993d44";
    hash = "sha256-+UIqBnzyeIOvJSKYaDaE3GYPEpLw7qQqyUw5S971AfU=";
  };

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

  improve = fetchFromGitHub {
    owner = "shadcn";
    repo = "improve";
    rev = "cac56e1ebd3c279aa9153616cfeac7b174ab90f9";
    hash = "sha256-czQV2LzhVddiT6kz0Wf3z+hHqGBgl4Zh/qw6hN3qEQw=";
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

  nativeBuildInputs = [ (python3.withPackages (ps: [ ps.pyyaml ])) ];

  installPhase = ''
    runHook preInstall

    python ${./install-skills.py} "$out/share/skills/agent-skills" \
      anthropic=${anthropicSkills}/skills \
      ast-grep=${astGrep}/ast-grep/skills \
      i-have-adhd=${iHaveAdhd}/skills \
      improve=${improve}/skills \
      kill-ai-slop=${killAiSlop}/skill \
      mattpocock=${mattPocockSkills}/skills \
      obelisk=${obelisk}/skills \
      pstack=${pstack}/skills

    runHook postInstall
  '';

  meta = {
    description = "Agent skills for code analysis, design, writing, research, learning, and session management";
    license = with lib.licenses; [
      asl20
      mit
    ];
    platforms = lib.platforms.all;
  };
}
