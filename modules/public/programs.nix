{
  pkgs,
  ...
}:
{
  environment.variables = {
    EDITOR = "hx";
    VISUAL = "hx";
    SUDO_EDITOR = "nvim --clean";
  };
  environment.systemPackages = with pkgs; [
    nushell
    neovim
    helix

    age
    yq
    nmap
    lsof
    tealdeer
    tokei
    rsync
    openssl
  ];
}
