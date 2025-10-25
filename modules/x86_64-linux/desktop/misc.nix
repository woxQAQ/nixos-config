{
  pkgs,
  ...
}:
{
  programs = {
    dconf.enable = true;
    localsend.enable = true;
    clash-verge = {
      enable = true;
      autoStart = false;
      # serviceMode = true;
      # tunMode = true;
    };
    thunar = {
      enable = true;
      plugins = with pkgs.xfce; [
        thunar-archive-plugin
        thunar-volman
      ];
    };
  };
  services = {
    dbus = {
      enable = true;
    };

    ollama = {
      enable = false;
      port = 11111;
      loadModels = [
        "nomic-embed-text"
      ];
      acceleration = "rocm";
      environmentVariables = {
        HCC_AMDGPU_TARGET = "gfx1010";
      };
      rocmOverrideGfx = "10.1.0";
    };
    keyd = {
      enable = true;
      keyboards.default.settings = {
        main = {
          capslock = "overload(control, esc)";
          esc = "capslock";
        };
      };
    };
  };

}
