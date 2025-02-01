{ ... }:
{
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };
  security.rtkit.enable = true; # 可选，但推荐启用以获得更好的实时音频性能
}
