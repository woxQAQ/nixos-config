{
  stable-pkg,
  unstable-pkg,
  ...
}:
{
  home.packages = with stable-pkg; [
    # mihomo-party
    vscode
    localsend
    buf
    hugo
    ollama
    # unstable-pkg.bitwarden-desktop
  ];
}
