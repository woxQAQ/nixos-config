{
  pkgs,
  unstable-pkg,
  ...
}: {
  environment.shells = with pkgs; [
    bashInteractive
    unstable-pkg.nushell
  ];
  environment.systemPackages = with pkgs; [
    gnumake
    ntfs3g
  ];
  users.defaultUserShell = pkgs.bashInteractive;
  programs = {
    dconf.enable = true;
    localsend.enable = true;
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
    gnome.gnome-keyring = {
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
  };
}
