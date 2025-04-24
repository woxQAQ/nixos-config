{
  unstable-pkg,
  config,
  lib,
  ...
}: {
  home.packages = with unstable-pkg; [
    kubectl
    kubecm
    kubernetes-helm
    argocd
    kubebuilder
  ];
  programs = {
    k9s = {
      enable = true;
      settings = {
        skin = "catppuccino-mocha";
      };
    };
  };
}
