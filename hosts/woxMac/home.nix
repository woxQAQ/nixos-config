{
  stable-pkg,
  unstable-pkg,
  ...
}: {
  home.packages = with stable-pkg; [
    # mihomo-party
    vscode
    localsend
    kubectl
    buf
    # unstable-pkg.bitwarden-desktop
  ];
}
