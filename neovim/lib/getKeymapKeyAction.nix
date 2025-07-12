{lib}: rec {
  # Simple keymap creation functions
  n = key: action: {
    mode = "n";
    inherit key action;
  };

  v = key: action: {
    mode = "v";
    inherit key action;
  };

  i = key: action: {
    mode = "i";
    inherit key action;
  };

  t = key: action: {
    mode = "t";
    inherit key action;
  };

  # Helper for adding descriptions
  desc = description: {options.desc = description;};

  # Helper for silent keymaps
  silent = {options.silent = true;};

  # Backward compatibility functions
  normal = lib.mapAttrsToList (key: action:
    if builtins.isString action
    then n key action
    else
      n key action.action
      // (
        if builtins.hasAttr "desc" action
        then desc action.desc
        else {}
      ));

  visual = lib.mapAttrsToList (key: action:
    if builtins.isString action
    then v key action
    else
      v key action.action
      // (
        if builtins.hasAttr "desc" action
        then desc action.desc
        else {}
      ));

  actionWithDesc = action: desc: {
    inherit action desc;
  };
}
