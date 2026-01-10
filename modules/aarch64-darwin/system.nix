{ lib, username, ... }:
{
  nix = {
    enable = false;
    settings = {
      auto-optimise-store = false;
      trusted-users = [ username ];
    };
    gc = {
      automatic = lib.mkDefault false;
      interval = {
        Weekday = 0;
        Hour = 0;
        Minute = 0;
      };
      options = lib.mkDefault "--delete-older-than 7d";
    };
  };
  system = {
    primaryUser = username;
    defaults = {
      menuExtraClock.Show24Hour = true;
      dock = {
        # keep-sorted start
        autohide = true;
        expose-group-apps = true;
        mru-spaces = false;
        show-recents = false;
        # keep-sorted end
      };
      loginwindow = {
        SHOWFULLNAME = true;
        GuestEnabled = false;
      };
      trackpad = {
        Clicking = true;
        TrackpadRightClick = true;
        TrackpadThreeFingerDrag = true;
      };
      finder = {
        _FXShowPosixPathInTitle = true;
        FXEnableExtensionChangeWarning = false;
        AppleShowAllExtensions = true;
        QuitMenuItem = true;
        ShowStatusBar = true;
        ShowPathbar = true;
      };
      CustomUserPreferences = {
        ".GlobalPreferences" = {
          AppleSpacesSwitchOnActivate = true;
        };
        NSGlobalDomain = {
          WebKitDeveloperExtras = true;
        };
        "com.apple.finder" = {
          AppleShowAllFiles = true;
          ShowExternalHardDrivesOnDesktop = true;
          ShowHardDrivesOnDesktop = true;
          ShowMountedServersOnDesktop = true;
          ShowRemovableMediaOnDesktop = true;
          _FXSortFoldersFirst = true;
          FXDefaultSearchScope = "SCcf";
        };
        "com.apple.spaces" = {
          "spans-displays" = true;
        };
      };
    };
    keyboard = {
      enableKeyMapping = true;
      remapCapsLockToControl = false;
      remapCapsLockToEscape = true;
      swapLeftCommandAndLeftAlt = false;
      userKeyMapping = [
        {
          HIDKeyboardModifierMappingSrc = 30064771113; # Caps Lock
          HIDKeyboardModifierMappingDst = 30064771129; # Escape
        }
      ];
    };
  };
}
