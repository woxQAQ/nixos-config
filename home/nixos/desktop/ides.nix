{ pkgs, ... }:
{
  home.packages = with pkgs; [
    code-cursor
  ];
  programs = {
    vscode = {
      enable = true;
      package = pkgs.vscode.override {
        isInsiders = false;
        commandLineArgs = [
          "--ozone-platform-hint=auto"
          "--ozone-platform-platform=wayland"
          "--gtk-version=4"
          "--enable-wayland-ime"
          "--password-store=gnome"
        ];
      };
    };
  };
}
