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

  # TERMINFO_DIRS already searches the system and user profiles directly.
  # Avoid pulling the whole system-path closure into etc for a redundant link.
  environment.etc.terminfo.enable = false;

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
