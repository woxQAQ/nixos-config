{
  config,
  lib,
  username,
  ...
}:
let
  nixProfile = "/nix/var/nix/profiles/default";
  nixBin = "${nixProfile}/bin";
  nixCollectGarbage = "${nixBin}/nix-collect-garbage";
  nixStore = "${nixBin}/nix-store";

  gcInterval = {
    Weekday = 0;
    Hour = 3;
    Minute = 15;
  };
  userGcInterval = {
    Weekday = 0;
    Hour = 3;
    Minute = 30;
  };
  optimiseInterval = {
    Weekday = 0;
    Hour = 4;
    Minute = 15;
  };

  gcScript = ''
    if [ -x "${nixCollectGarbage}" ]; then
      exec "${nixCollectGarbage}" --delete-older-than 7d
    fi
  '';
  optimiseScript = ''
    if [ -x "${nixStore}" ]; then
      exec "${nixStore}" --optimise
    fi
  '';
in
{
  nix = {
    enable = false;
    settings = {
      auto-optimise-store = false;
      trusted-users = [ username ];
    }
    // lib.optionalAttrs config.nix.enable {
      keep-derivations = lib.mkDefault false;
      keep-outputs = lib.mkDefault false;
      min-free = lib.mkDefault (10 * 1024 * 1024 * 1024);
      max-free = lib.mkDefault (30 * 1024 * 1024 * 1024);
    };
    gc = lib.mkIf config.nix.enable {
      automatic = lib.mkDefault true;
      interval = lib.mkDefault gcInterval;
      options = lib.mkDefault "--delete-older-than 7d";
    };
    optimise = lib.mkIf config.nix.enable {
      automatic = lib.mkDefault true;
      interval = lib.mkDefault optimiseInterval;
    };
  };

  launchd.daemons = lib.mkIf (!config.nix.enable) {
    nix-gc = {
      script = gcScript;
      serviceConfig = {
        RunAtLoad = false;
        StartCalendarInterval = gcInterval;
      };
    };
    nix-user-gc = {
      script = gcScript;
      serviceConfig = {
        RunAtLoad = false;
        StartCalendarInterval = userGcInterval;
        UserName = username;
      };
    };
    nix-optimise = {
      script = optimiseScript;
      serviceConfig = {
        RunAtLoad = false;
        StartCalendarInterval = optimiseInterval;
      };
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
