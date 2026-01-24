{ pkgs, ... }:
{
  programs = {
    gnupg.agent = {
      enable = true;
      pinentryPackage = pkgs.pinentry-qt;
      enableSSHSupport = false;
      settings.default-cache-ttl = 4 * 60 * 60; # 4 hours
    };
    seahorse.enable = true;
    ssh.startAgent = true;
  };
  services.gnome = {
    gcr-ssh-agent.enable = false;
    gnome-keyring = {
      enable = true;
    };
  };
  security.pam.services.greetd.enableGnomeKeyring = true;

  security.polkit.enable = true;
}
