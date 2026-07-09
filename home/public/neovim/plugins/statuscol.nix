let
  foldfunc = {
    __raw = /* lua */ ''
      (function()
        local builtin = require("statuscol.builtin")
        local ffi = require("statuscol.ffidef")
        local C = ffi.C
        local fold_level_limit = 3

        return function(args)
          local foldinfo = C.fold_info(args.wp, args.lnum)
          if foldinfo.level > fold_level_limit then
            return " "
          end

          return builtin.foldfunc(args)
        end
      end)()
    '';
  };
in
{
  plugins.statuscol = {
    enable = true;
    settings = {
      relculright = false;
      segments = [
        {
          text = [ "%s" ];
          click = "v:lua.ScSa";
        }
        {
          text = [
            { __raw = "require('statuscol.builtin').lnumfunc"; }
            " "
          ];
          click = "v:lua.ScLa";
        }
        {
          text = [
            foldfunc
            " "
          ];
          condition = [
            true
            { __raw = "require('statuscol.builtin').not_empty"; }
          ];
          click = "v:lua.ScFa";
        }
      ];
    };
  };
}
