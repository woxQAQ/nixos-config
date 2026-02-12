_: {
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      X11Forwarding = true;
    };
  };

  environment.enableAllTerminfo = true;
}
