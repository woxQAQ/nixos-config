{ pkgs, ... }:
{
  programs.nix-ld = {
    enable = true;
    libraries = with pkgs; [
      zlib
      zstd
      libcap
      openssl
      stdenv.cc.cc
      curl
      glib
      attr
      libssh
      libseccomp
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
}
