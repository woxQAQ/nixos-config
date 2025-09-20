_: {
  security.pam.services.sudo_local.touchIdAuth = true;
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = false;
  };
}
