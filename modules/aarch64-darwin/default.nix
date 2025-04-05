{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    treefmt
    alejandra
    nil
  ];
  security.pam.enableSudoTouchIdAuth = true;
  imports = [
    ./usergroup.nix
    ./brew.nix
  ];
  services.nix-daemon.enable = true;
  nix.package = pkgs.nix;
}
