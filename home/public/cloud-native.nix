{
  unstable-pkg,
  lib,
  ...
}:
let
  # Podman 相关工具包组
  podmanPackages = with unstable-pkg; [
    podman
    podman-compose
    podman-tui
  ];

  # 其他云原生工具
  otherCloudNativePackages = with unstable-pkg; [
    kubernetes-helm
    kubebuilder
  ];

  # 是否启用 podman
  enablePodman = true; # 可以通过配置控制是否安装 podman 相关工具
in
{
  home.packages = otherCloudNativePackages ++ lib.optionals enablePodman podmanPackages;

  programs = {
    k9s = {
      enable = false;
      settings = {
        skin = "catppuccino-mocha";
      };
    };
  };
}
