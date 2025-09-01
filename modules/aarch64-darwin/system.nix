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
    defaults = {
      dock = {
        autohide = false;
        show-recents = true;
        mru-spaces = false;
        expose-group-apps = true;
      };
      loginwindow = {
        SHOWFULLNAME = true;
        GuestEnabled = false;
      };
      trackpad = {
        Clicking = true;
        TrackpadRightClick = true;
      };
      finder = {
        _FXShowPosixPathInTitle = true;
        AppleShowAllExtensions = true;
        QuitMenuItem = true;
        ShowStatusBar = true;
        ShowPathbar = true;
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
