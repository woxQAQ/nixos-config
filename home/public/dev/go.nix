{
  pkgs,
  config,
  ...
}:
{
  programs.go = {
    enable = true;
    package = pkgs.go_1_24;
    env = {
      GOBIN = "${config.home.homeDirectory}/go/bin";
      GOPATH = "${config.home.homeDirectory}/go";
    };
  };
  home.packages = with pkgs; [
    # golang lsp
    gopls
    # staticcheck,goimports for golang
    go-tools
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
