{pkgs, ...}: {
  homebrew = {
    enable = true;
  };
  onActivation = {
    autoUpdate = false;
  };
  taps = [
    "homebrew/services"
  ];
}
