{lib, ...}: {
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
}
