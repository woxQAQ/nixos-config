{
  system.defaults = {
    dock = {
      # keep-sorted start

      autohide = true;
      # remove delay for showing dock
      autohide-delay = 0.0;
      # how fast is the dock showing animation
      autohide-time-modifier = 1.0;
      expose-group-apps = true;
      mru-spaces = false;
      show-recents = false;
      static-only = false;
      tilesize = 50;
      wvous-bl-corner = 14;
      wvous-br-corner = 4;
      # Hot corners
      # Possible values:
      #  0: no-op
      #  2: Mission Control
      #  3: Show application windows
      #  4: Desktop
      #  5: Start screen saver
      #  6: Disable screen saver
      #  7: Dashboard
      # 10: Put display to sleep
      # 11: Launchpad
      # 12: Notification Center
      # 13: Lock Screen
      # 14: Quick Notes
      wvous-tl-corner = 2;
      wvous-tr-corner = 12;
      # keep-sorted end

    };
    finder = {
      # keep-sorted start
      AppleShowAllExtensions = true;
      AppleShowAllFiles = true;
      CreateDesktop = false;
      FXDefaultSearchScope = "SCcf";
      FXEnableExtensionChangeWarning = false;
      FXPreferredViewStyle = "Nlsv";
      QuitMenuItem = true;
      ShowExternalHardDrivesOnDesktop = false;
      ShowHardDrivesOnDesktop = false;
      ShowMountedServersOnDesktop = false;
      ShowPathbar = true;
      ShowRemovableMediaOnDesktop = false;
      ShowStatusBar = false;
      _FXShowPosixPathInTitle = true;
      _FXSortFoldersFirst = true;
      # keep-sorted end
    };

    loginwindow = {
      SHOWFULLNAME = true;
      GuestEnabled = false;
    };

    menuExtraClock.Show24Hour = true;

    CustomUserPreferences = {
      "com.apple.finder" = {
        AppleShowAllFiles = true;
        ShowExternalHardDrivesOnDesktop = true;
        ShowHardDrivesOnDesktop = true;
        ShowMountedServersOnDesktop = true;
        ShowRemovableMediaOnDesktop = true;
        _FXSortFoldersFirst = true;
        FXDefaultSearchScope = "SCcf";
        DisableAllAnimations = true;
      };
    };
  };
}
