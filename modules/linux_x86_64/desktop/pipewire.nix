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
  security.rtkit.enable = true; # 可选，但推荐启用以获得更好的实时音频性能
  environment.systemPackages = with pkgs; [ pulseaudioFull ];
}
