{
  username,
  ...
}:
{
  imports = [
    ./inputs.nix
    ./ui.nix
    ./nix.nix
  ];

  system = {
    primaryUser = username;
    defaults = {
      CustomUserPreferences = {
        ".GlobalPreferences" = {
          AppleSpacesSwitchOnActivate = true;
        };
        NSGlobalDomain = {
          WebKitDeveloperExtras = true;
        };

        "com.apple.spaces" = {
          "spans-displays" = true;
        };
      };
    };

  };
}
