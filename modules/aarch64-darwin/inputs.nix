{
  system = {
    defaults = {
      trackpad = {
        Clicking = true;
        ActuationStrength = 0;
        # don't allow positional right click
        TrackpadRightClick = true;
        # three finger drag
        TrackpadThreeFingerDrag = true;
      };
      ".GlobalPreferences" = {
        "com.apple.mouse.scaling" = 1.0;
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
