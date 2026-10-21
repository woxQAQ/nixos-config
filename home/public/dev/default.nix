{
  pkgs,
  ...
}:
{
  imports = [
    ./go.nix
    ./npm.nix
    ./cloud-native.nix
    ./nix.nix
  ];
  home.packages = with pkgs; [
    ### NODEJS
    pnpm
    nodejs_24
    oxfmt
    bun
    pandoc
    typst
    mdbook

    ### C/C++
    # clang
    # clang-tools

    ### RUST ###
    rustfmt
    rustc
    cargo
    rust-analyzer

    ### PYTHON ###
    (python3.withPackages (
      ps: with ps; [
        pyyaml
      ]
    ))
    uv
    black
    ruff

    ### JAVA ###
    # zulu23
    # maven

    ### PROTOBUF ###
    protobuf
    protols

    ### UTILS ###
    gdb
    checkmake
    shellspec

    ### MISC ###
    # useful leetcode cli
    leetgo
    # 仓库工作流的入口（justfile / Makefile 都转调它），devShell 之外同样需要，
    # 因此装进 home 层而非只留在 outputs/dev 的 shell 里。
    just
    nufmt
    ast-grep
    dbeaver-bin
  ];
  # home.file.".npmrc".text = ''
  #   prefix=~/.npm-packages
  # '';
  home.sessionPath = [
    "$HOME/go/bin"
    "$HOME/.npm/bin"
    "$HOME/.kimi-code/bin"
  ];
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
    enableBashIntegration = true;
    enableZshIntegration = true;
    enableNushellIntegration = true;
  };
}
