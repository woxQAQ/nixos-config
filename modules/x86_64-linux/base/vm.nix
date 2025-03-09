{...}: {
  virtualisation = {
    waydroid.enable = false;

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
