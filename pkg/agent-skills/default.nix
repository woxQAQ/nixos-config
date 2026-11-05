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
    rev = "ca45fc496a3436251f191354091d557da31c15b5";
    hash = "sha256-MkCOANBAqCc1WmNf7S8PsyAphGJAIzEXGyCm8RrCR9M=";
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

  mattPocockSkills = fetchFromGitHub {
    owner = "mattpocock";
    repo = "skills";
    rev = "4ae2317ddb22b046e26455e4f9c9b3aaaf62212d";
    hash = "sha256-3vhd77xfZjKUYJsIwPFevIZPUAzUgZXr0RYj5NQrBwk=";
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
    rev = "4ae1636abe217c7215774bf6b2265916a5c5f648";
    hash = "sha256-enRz+0Yv6U+wHDJk9Sdl6FzwMLUoQsBqoJUL1W3SM/w=";
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
