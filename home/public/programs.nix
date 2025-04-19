{
  pkgs,
  ...
}: {
  home.packages = with pkgs; [
    mihomo-party
  ];
}