{ pkgs, ... }:
{
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
    wireplumber.enable = true;
  };
  services.udev.packages = with pkgs; [
    gnome-settings-daemon
  ];
  security.rtkit.enable = true;
  services.pulseaudio.enable = false;
  environment.systemPackages = with pkgs; [ pulseaudio ];
}
