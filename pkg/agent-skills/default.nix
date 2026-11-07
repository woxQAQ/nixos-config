{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  applyPatches,
  python3,
}:
let
  anthropicSkills = fetchFromGitHub {
    owner = "anthropics";
    repo = "skills";
    rev = "2c5958ecac7cee2b583967a2c4981d0f4a75c579";
    hash = "sha256-dRCZrNarCCJFuvATgfW6qmwwVS5HGFXNVGOhbVZd7LA=";
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
      rev = "4ae2317ddb22b046e26455e4f9c9b3aaaf62212d";
      hash = "sha256-3vhd77xfZjKUYJsIwPFevIZPUAzUgZXr0RYj5NQrBwk=";
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
    rev = "e7c0e358c82a609d53f1f1045572dbc0fd965bfc";
    hash = "sha256-Z0nw4J1qOrbh2VYErq2PpjibhZskW61FeNuaPF4Azvs=";
  };

  pstack = fetchFromGitHub {
    owner = "backnotprop";
    repo = "pstack";
    rev = "f104aa8f821a3f7397318b0dc8ad2f7e4a1f8bc7";
    hash = "sha256-VPgYiNBX4J8TuaoWAkd9xG7DxDcKZaTLj3ILo0uf1jc=";
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
