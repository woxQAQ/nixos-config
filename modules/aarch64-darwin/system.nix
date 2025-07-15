{ lib, ... }:
{
  nix = {
    gc = {
      automatic = lib.mkDefault true;
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
      };
      loginwindow = {
        SHOWFULLNAME = true;
        GuestEnabled = false;
      };
      trackpad = {
        Clicking = true;
      };
      finder = {
        _FXShowPosixPathInTitle = true;
        AppleShowAllExtensions = true;
        ShowStatusBar = true;
        ShowPathbar = true;
      };
    };
  };
}
