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
            {
              __raw = "require('statuscol.builtin').lnumfunc";
            }
          ];
          click = "v:lua.ScLa";
        }
        {
          text = [
            {
              __raw = ''
                function(args)
                local ffi = require("statuscol.ffidef")
                local C = ffi.C
                local foldinfo = C.fold_info(args.wp, args.lnum)
                if foldinfo.level > 3 then
                  return " "
                end
                return require('statuscol.builtin').foldfunc(args)
                end
              '';
            }
          ];
          condition = [
            true
            {
              __raw = "require('statuscol.builtin').not_empty";
            }
          ];
          click = "v:lua.ScFa";
        }
      ];
    };
  };
}
