{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    wget
    gnumake
    killall
    pkgs.nixfmt-rfc-style
  ];
  environment.variables.EDITOR = "vim";
  system.stateVersion = "24.11"; # Did you read the comment?
  time.timeZone = "Asia/Shanghai";
  i18n.defaultLocale = "en_US.UTF-8";
}
