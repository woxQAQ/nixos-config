{ pkgs, ... }:
{
  programs.nix-ld = {
    enable = true;
    libraries = with pkgs; [
      zlib
      zstd
      stdenv.cc.cc
      curl
      glib
      openssl
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
