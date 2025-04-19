{
  stable-pkg,
  unstable-pkg,
  ...
}: {
  home.packages = with stable-pkg; [
    # mihomo-party
    vscode
    unstable-pkg.bitwarden-desktop
  ];
}
