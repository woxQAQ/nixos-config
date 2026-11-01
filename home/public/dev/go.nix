{
  fastest-pkg,
  pkgs,
  config,
  ...
}:
{
  programs.go = {
    enable = true;
    # Keep nixpkgs-fast pinned for Zotero; update the Go source independently.
    package = fastest-pkg.go_1_27.overrideAttrs (
      finalAttrs: _previousAttrs: {
        version = "1.27.3";
        src = fastest-pkg.fetchurl {
          url = "https://go.dev/dl/go${finalAttrs.version}.src.tar.gz";
          hash = "sha256-bndJA1zzYPBrJXXRYup535/ajvZxiJ5cN1+OUHd/Jrs=";
        };
      }
    );
    env = {
      GOBIN = "${config.home.homeDirectory}/go/bin";
      GOPATH = "${config.home.homeDirectory}/go";
    };
  };
  home.packages = with pkgs; [
    # golang lsp
    gopls
    # staticcheck,goimports for golang
    gotools
    # golang linter
    golangci-lint
    # golang debugger
    delve
    # formatter strict than gofmt
    gofumpt
    # formatter for long lines
    golines

    # make alternative
    go-task

    # graph generate for pprof
    graphviz
  ];
}
