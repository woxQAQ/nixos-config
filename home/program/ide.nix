{pkgs, ...}: {
  home.packages = with pkgs; [
    zed-editor
    code-cursor
    vscode
  ];
}
