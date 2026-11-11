{
  pkgs,
  ...
}:
{
  environment.systemPackages = with pkgs; [
    crosspipe
    pulsemixer
    pavucontrol
    pwvucontrol
    qpwgraph
    easyeffects
    qjackctl
  ];
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
    wireplumber.enable = true;
  };
  services.pulseaudio.enable = false;

  services.udev.packages = with pkgs; [
    gnome-settings-daemon
  ];
  security.rtkit.enable = true;
}
