{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    git
    git-lfs
    fastfetch
    lsof
    tldr

    wget
    curl
    aria2
    nmap

    which
    tree
    rsync
    file

    gnumake
    killall
    nil
    treefmt
    alejandra

    zip
    unar
    gnutar
    unzipNLS
    xz
    p7zip
    zstd

    gnugrep
    gnused
    gawk
    jq
    (writeShellScriptBin "python" ''
      export LD_LIBRARY_PATH=$NIX_LD_LIBRARY_PATH
      exec ${python3}/bin/python "$@"
    '')
  ];
  programs.nix-ld = {
    enable = true;
    libraries = with pkgs; [
      zlib
      zstd
      stdenv.cc.cc
      curl
      openssl
      attr
      libssh
      bzip2
      libxml2
      acl
      libsodium
      util-linux
      xz
      systemd
      libgcc
    ];
  };

  environment.variables.EDITOR = "vim";
  nix.settings.substituters = [
    "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store"
    "https://mirrors.sustech.edu.cn/nix-channels/store"
    "https://nix-community.cachix.org"
  ];
  nix.settings.trusted-public-keys = [
    "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    "anyrun.cachix.org-1:pqBobmOjI7nKlsUMV25u9QHa9btJK65/C8vnO3p346s="
  ];
  nix.settings.builders-use-substitutes = true;
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];
}
