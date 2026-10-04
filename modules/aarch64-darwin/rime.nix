{
  config,
  lib,
  ...
}:
let
  cfg = config.modules.darwin.rime;
in
{
  options.modules.darwin.rime = {
    enable = lib.mkEnableOption "Rime input method (Squirrel) with the rime-ice schema";
  };

  config = lib.mkIf cfg.enable {
    # listOf 的多个定义会拼接，这里把 squirrel-app 注入 brew 模块，
    # 使输入法本体与其配置模块保持内聚
    modules.darwin.brew.casks = [ "squirrel-app" ];
  };
}
