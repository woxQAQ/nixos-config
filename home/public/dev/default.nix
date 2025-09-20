{
  pkgs,
  ...
}:
{
  imports = [
    ./git.nix
    ./go.nix
    ./claude-code.nix
  ];
  home.packages = with pkgs; [
    ### NODEJS
    pnpm
    yarn
    nodejs_20
    bun

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
    # replace of df
    duf
    # replace of du
    gdu
    du-dust
    # replace of find
    fd
    # rg
    ripgrep
    # yaml lint and processor
    yq
    nodePackages.jsonlint
    checkmake
    shellspec

    ### MISC ###
    # useful leetcode cli
    leetgo
    # llm cli
    aichat
    # database Management GUI
    dbeaver-bin
  ];
  # home.file.".npmrc".text = ''
  #   prefix=~/.npm-packages
  # '';
  home.sessionPath = [
    "$HOME/go/bin"
    "$HOME/.npm/bin"
  ];
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
    enableBashIntegration = true;
    enableZshIntegration = true;
    enableNushellIntegration = true;
  };
}
