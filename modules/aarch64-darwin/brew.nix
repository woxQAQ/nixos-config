{
  pkgs,
  unstable-pkg,
  ...
}: {
  environment.systemPackages = with pkgs; [
    git
    gnugrep
  ];
  environment.shells = [
    pkgs.zsh
    unstable-pkg.nushell
  ];
  homebrew = {
    enable = true;
    onActivation = {
      autoUpdate = false;
    };
    taps = [
    ];
  };
}
