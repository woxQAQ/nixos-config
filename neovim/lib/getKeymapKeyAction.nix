{lib, ...}: let
  key_ = mode_:
    lib.mapAttrsToList (key: action_:
      if builtins.isString action_
      then {
        mode = mode_;
        action = action_;
        inherit key;
      }
      else if !builtins.hasAttr "action" action_
      then throw "bad action when define a keymap"
      else if builtins.hasAttr "desc" action_
      then {
        mode = mode_;
        action = action_.action;
        inherit key;
        options.desc = action_.desc;
      }
      else {
        mode = mode_;
        action = action_.action;
        inherit key;
      });
in {
  normal = key_ "n";
  visual = key_ "v";
  actionWithDesc = action: desc: {
    inherit action desc;
  };
}
