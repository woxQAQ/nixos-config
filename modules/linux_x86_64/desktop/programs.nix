{ pkgs, ... }:
{
  programs = {
    localsend.enable = true;
    dconf.enable = true;
  };
  environment.systemPackages = with pkgs; [
    ntfs3g
  ];
}
