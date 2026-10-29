{
  mylib,
  inputs,
  system,
  ...
}@args:
let
  name = "woxMac";
  darwin-modules = [
    inputs.agenix.darwinModules.default
    ../hosts/${name}
    ../modules/${system}
    ../modules/public
    ../secrets/darwin.nix
    {
      modules.darwin = {
        rime.enable = true;
        brew.casks = [
          # keep-sorted start
          "feishu"
          "google-chrome"
          # nixpkgs pins koodo-reader to electron_41, which is marked EOL/insecure;
          # the cask ships the upstream-signed binary instead
          # "koodo-reader"
          # a gba emulators to play gba games
          "mgba-app"
          # Open broadcast studio
          "obs"
          "pixpin"
          "raycast"
          # keep-sorted end
        ];
      };
    }
  ];
  home-modules = [
    ../home/darwin
  ]
  ++ [
    ../home/agents
    inputs.hidpipe.homeManagerModules.default
    {
      # macOS 注入端。woxqaq.local 由 Linux 侧 avahi 发布;
      # 首次运行需在 系统设置 → 辅助功能 授权(launchd 项名为 hidpipe-client,
      # nix store 路径更新后需要重新授权)。
      services.hidpipe = {
        enable = true;
        host = "woxqaq.local";
      };
    }
    {
      modules.agents = {
        profile = "terminal";
      };
    }
    ../home/public
    {
      modules.public = {
        cloud-native.enable = true;
        desktop.enable = true;
        neovim.enable = true;
        helix.enable = true;
        playwright.enable = true;
        terminal = {
          emulators = [
            "ghostty"
          ];
          font-size = 15;
          font-family = "IoskeleyMonoTerm Nerd Font Mono";
          # Yozai(悠哉字体) 的手写圆润字形作为 CJK fallback
          # font-family-fallbacks = [ "Yozai" ];
        };
      };
    }
  ];
  modules_ = {
    inherit darwin-modules home-modules;
    username = "woxqaq";
    hostname = name;
  };
in
{
  darwinConfigurations = {
    "${name}" = mylib.mkDarwin (args // modules_);
  };
}
