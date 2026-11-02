_: {
  programs = {
    gnupg.agent = {
      enable = true;
      enableSSHSupport = false;
      settings.default-cache-ttl = 4 * 60 * 60; # 4 hours
    };
    ssh.startAgent = true;
  };
  services.gnome = {
    gcr-ssh-agent.enable = false;
    gnome-keyring = {
      enable = true;
    };
  };
  services.openssh.settings = {
    PermitRootLogin = "no";
    X11Forwarding = true;
  };
  security.polkit.enable = true;
}
