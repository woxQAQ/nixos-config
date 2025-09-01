{
  stable-pkg,
  ...
}:
{
  home.packages = with stable-pkg; [
    # mihomo-party
    localsend
    buf
  ];
}
