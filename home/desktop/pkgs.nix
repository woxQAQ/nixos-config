{ pkgs, lib, ... }:
let
  flatpakUserFontFilesystems = [
    "/etc/fonts:ro"
    "/nix/store:ro"
    "/run/current-system/sw/share/X11/fonts:ro"
    "/run/current-system/sw/share/fonts:ro"
    "xdg-config/fontconfig:ro"
    "xdg-data/fonts:ro"
    "~/.fonts:ro"
    "~/.local/share/fonts:ro"
  ];
  flatpakUserFontOverrideArgs = lib.concatMapStringsSep " " (
    filesystem: "--filesystem=${lib.escapeShellArg filesystem}"
  ) flatpakUserFontFilesystems;
in
{
  home.packages = with pkgs; [
    wev
  ];

  home.activation.flatpakUserFontOverrides = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    if command -v flatpak >/dev/null 2>&1; then
      run flatpak override --user ${flatpakUserFontOverrideArgs}
    fi
  '';

  fonts.fontconfig.enable = false;
}
