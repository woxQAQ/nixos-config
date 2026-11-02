{ lib, ... }: {
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      X11Forwarding = true;
      PermitRootLogin = lib.mkDefault "prohibit-password";
      KbdInteractiveAuthentication = false;
    };

  };
  environment.enableAllTerminfo = true;
}
