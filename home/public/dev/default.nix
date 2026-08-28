{
  pkgs,
  fastest-pkg,
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
    yarn
    nodejs_22
    bun
    pandoc
    fastest-pkg.devenv
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
    nufmt
    ast-grep
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
