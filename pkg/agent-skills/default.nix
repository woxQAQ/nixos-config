{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
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

  mattPocockSkills = fetchFromGitHub {
    owner = "mattpocock";
    repo = "skills";
    rev = "abeeaf95660ba9e8b7c753eb38f441ca707a8823";
    hash = "sha256-fc5+qmchp1IQ/rQP1olWKC1eC4VdYhaB7YYzC3+JBe0=";
  };

  pstack = fetchFromGitHub {
    owner = "backnotprop";
    repo = "pstack";
    rev = "9dd340887a043aa1da07a0d5c4e6918bbb3a02a0";
    hash = "sha256-CTRN0y018Xlmnxb5Y0Zm/VPxMqVrA/wOrEkmY/nn/R4=";
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
