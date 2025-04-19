{
  stable-pkg,
  unstable-pkg,
  ...
}: {
  home.packages = with stable-pkg; [
    # mihomo-party
    vscode
    localsend
    # unstable-pkg.bitwarden-desktop
  ];
}
