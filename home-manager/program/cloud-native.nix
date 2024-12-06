{
  pkgs,
  config,
  inputs,
  ...
}:
{
  home.packages = with pkgs; [
    podman
    docker-compose
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