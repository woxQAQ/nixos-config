{ lib }:
rec {
  # Enhanced keymap creation with better readability
  # Basic mode creators
  # Enhanced keymap with options
  keymap = mode: key: action: options: {
    inherit
      mode
      key
      action
      options
      ;
  };

  # Multi-mode keymap support
  multimode =
    modes: key: action: options:
    map (mode: keymap mode key action options) (lib.toList modes);

  # Convenient helpers with flexible options (descriptive names)
  normal =
    key: action: desc: options:
    keymap "n" key action ({ inherit desc; } // options);
  visual =
    key: action: desc: options:
    keymap "v" key action ({ inherit desc; } // options);
  insert =
    key: action: desc: options:
    keymap "i" key action ({ inherit desc; } // options);
  terminal =
    key: action: desc: options:
    keymap "t" key action ({ inherit desc; } // options);

  # Multi-mode helpers
  nv =
    key: action: desc: options:
    multimode [ "n" "v" ] key action ({ inherit desc; } // options);
  ni =
    key: action: desc: options:
    multimode [ "n" "i" ] key action ({ inherit desc; } // options);
  nvi =
    key: action: desc: options:
    multimode [ "n" "v" "i" ] key action ({ inherit desc; } // options);
  all =
    key: action: desc: options:
    multimode [ "n" "v" "i" "t" ] key action ({ inherit desc; } // options);

  # Backward compatibility aliases
  n = normal;
  v = visual;
  i = insert;
  t = terminal;

  # Group keymaps by category
  category = name: keymaps: {
    inherit name keymaps;
  };

  # Apply common options to multiple keymaps
  withOptions = options: keymaps: map (km: km // { options = km.options or { } // options; }) keymaps;

  # Legacy helpers for backward compatibility
  desc = description: { options.desc = description; };
  silent = {
    options.silent = true;
  };

  # Backward compatibility functions
  # normal = lib.mapAttrsToList (
  #   key: action:
  #   if builtins.isString action then
  #     n key action
  #   else
  #     n key action.action // (if builtins.hasAttr "desc" action then desc action.desc else { })
  # );
  #
  # visual = lib.mapAttrsToList (
  #   key: action:
  #   if builtins.isString action then
  #     v key action
  #   else
  #     v key action.action // (if builtins.hasAttr "desc" action then desc action.desc else { })
  # );

  actionWithDesc = action: desc: {
    inherit action desc;
  };
}
