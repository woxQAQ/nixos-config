{...}: {
  virtualisation = {
    containers = {
      enable = true;
    };
    docker = {
      enable = true;
      daemon.settings = {
        "features" = {
          "containerd-snapshotter" = true;
        };
        "registry-mirrors" = [
          "https://docker.m.daocloud.io"
        ];
      };
      enableOnBoot = true;
    };
  };
}
