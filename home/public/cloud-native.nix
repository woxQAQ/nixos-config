{pkgs, config,lib,...}: {
    home.packages = with pkgs; [
      kubectl
      kubecm
      kubernetes-helm
      argocd
      minikube
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
