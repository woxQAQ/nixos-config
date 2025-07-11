{
  unstable-pkg,
  config,
  lib,
  ...
}: {
  home.packages = with unstable-pkg; [
    kubernetes-helm
    kubebuilder
    podman
    podman-compose
  ];
  programs = {
    k9s = {
      enable = false;
      settings = {
        skin = "catppuccino-mocha";
      };
    };
  };
}
