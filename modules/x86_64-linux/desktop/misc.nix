{
  pkgs,
  ...
}:
{
  programs = {
    dconf.enable = true;
    thunar = {
      enable = true;
      plugins = with pkgs; [
        thunar-archive-plugin
        thunar-volman
        thunar-media-tags-plugin
      ];
    };
    # file-roller = {
    #   enable = true;
    #   package = pkgs.file-roller;
    # };
  };
  security.sudo.keepTerminfo = true;
  services = {
    gvfs.enable = true; # Mount, trash, and other functionalities
    tumbler.enable = true; # Thumbnail support for images
    dbus = {
      enable = true;
    };

    ollama = {
      enable = false;
      package = pkgs.ollama-rocm;
      port = 11111;
      loadModels = [
        "nomic-embed-text"
      ];
      environmentVariables = {
        HCC_AMDGPU_TARGET = "gfx1010";
      };
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
