{pkgs, ...}: {
  home.packages = with pkgs; [
    pot
  ];
}
