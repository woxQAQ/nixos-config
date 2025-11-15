{
  pkgs,
  lib,
  config,
  ...
}:
let
  cfg = config.modules.public.cloud-native;
in
{
  options.modules.public.cloud-native = {
    enable = lib.mkEnableOption "Cloud-native";
  };
  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      kubernetes-helm
      kubebuilder
      argocd
      kubectl
      kubectl-tree
      kubectl-view-secret
      dive
      lazydocker
      helm-ls
    ];

    programs = {
      k9s = {
        enable = true;
      };
    };
    catppuccin.k9s.transparent = true;
    programs.kubecolor = {
      enable = true;
      enableAlias = true;
    };
  };

}
