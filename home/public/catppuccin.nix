{ ... }:
{
  imports = [ ./catppuccin ];

  catppuccin = {
    enable = true;
    autoEnable = true;
    appearance = "auto";
    lightFlavor = "latte";
    flavor = "mocha";
    accent = "blue";
    # Cache endpoints and signing trust are managed in modules/public/system.nix.
    cache.enable = false;
    starship.enable = false;
    zed = {
      enable = false;
      flavor = "frappe";
      accent = "blue";
      icons.enable = false;
    };
  };
}
