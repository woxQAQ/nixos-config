{...}: {
  virtualisation = {
    waydroid.enable = true;

    containers = {
      enable = true;
    };
    docker = {
      enable = true;
      daemon.settings = {
        "features" = {
          "containerd-snapshotter" = true;
        };
      };

      enableOnBoot = true;
    };
  };
}
