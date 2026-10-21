{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.modules.public.terminal;
  ghosttyTerminfo =
    if pkgs.stdenv.hostPlatform.isDarwin then
      pkgs.ghostty-bin.terminfo
    else
      pkgs.ghostty.terminfo;
in
{
  config = lib.mkIf (lib.elem "ghostty" cfg.emulators) {
    home.file.".terminfo/78/xterm-ghostty".source =
      "${ghosttyTerminfo}/share/terminfo/78/xterm-ghostty";

    programs.ghostty = {
      enable = true;
      # ghostty 的 macOS 前端是 Swift/AppKit，无法在 Nix sandbox 中源码构建，
      # nixpkgs 在 Darwin 上仅有官方 dmg 的重打包 ghostty-bin
      package =
        if pkgs.stdenv.hostPlatform.isDarwin then pkgs.ghostty-bin else pkgs.ghostty;

      settings = lib.mkMerge [
        {
          # home-manager 对 list 值生成重复键，ghostty 依此按顺序构建 fallback 链
          font-family = [ cfg.font-family ] ++ cfg.font-family-fallbacks;
          inherit (cfg) font-size;
          font-feature = "feat";
          font-thicken = true;

          copy-on-select = false;
          cursor-style = "bar";
          cursor-style-blink = true;
          background-opacity = 0.95;
          window-padding-balance = true;

          command = "${pkgs.bash}/bin/bash --login -c 'nu --login --interactive'";
        }
        (lib.mkIf pkgs.stdenv.hostPlatform.isDarwin {
          # window-colorspace 仅 macOS 支持
          window-colorspace = "display-p3";
          window-decoration = "auto";
          background-blur-radius = 10;
        })
      ];
    };
  };
}
