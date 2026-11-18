{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  applyPatches,
  python3,
  neuve ? null,
}:
let
  anthropicSkills = fetchFromGitHub {
    owner = "anthropics";
    repo = "skills";
    rev = "e4bb5d960d87126ff3b3a8af1a104b7db67560ba";
    hash = "sha256-Gr9LatjawHHK9uKpoclWoiDHZ0NTpP3/4Pmeatl8p/Q=";
  };

  astGrep = fetchFromGitHub {
    owner = "ast-grep";
    repo = "agent-skill";
    rev = "0613dc7f82bbfb3b557380b54726b92f73358460";
    hash = "sha256-HFZVX/UYsct8EMtkczBGJNr9RjjDz77zY6SHS1WlKkc=";
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

  mattPocockSkills = applyPatches {
    src = fetchFromGitHub {
      owner = "mattpocock";
      repo = "skills";
      rev = "5863806dd4e15c63174bee4e7515a4256792ecfa";
      hash = "sha256-AYSRCvBL8TDDdW3rgKu2T7gl4YYDoDId0jYbabEFyfs=";
    };

    # Quote the description's colon so the published frontmatter is valid YAML.
    postPatch = ''
      substituteInPlace skills/in-progress/software-factory/SKILL.md \
        --replace-fail \
        'description: Shared language for designing a software factory: the tasks it runs and the services it plugs into.' \
        'description: "Shared language for designing a software factory: the tasks it runs and the services it plugs into."'
    '';
  };

  obelisk = fetchFromGitHub {
    owner = "tommy0103";
    repo = "obelisk-skill";
    rev = "506c221788d5377c08a297998f62e1783319a121";
    hash = "sha256-J5Pl8/ZFxbUODDRMNUyqpLgs32gGJcfW9i+sXnuX+5Y=";
  };

  pstack = fetchFromGitHub {
    owner = "backnotprop";
    repo = "pstack";
    rev = "83a729a182a29b59a2a42fc3d7736b0c376b55d4";
    hash = "sha256-uCCDUGr0sG7ormy9b/j1IXOroJvaZRVDb+tYmemHQ5k=";
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
      pstack=${pstack}/skills ${
        lib.optionalString (neuve != null) "neuve=${neuve}/share/neuve/skills"
      }

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
