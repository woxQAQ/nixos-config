{
  snacks = {
    enable = true;
    settings.picker = {
      actions = {
        calculate_file_truncate_width.__raw = ''
          function(self)
              local width = self.list.win:size().width
              self.opts.formatters.file.truncate = width - 6
          end
        '';
      };
      win = {
        list = {
          on_buf.__raw = ''
            function(self)
                self:execute 'calculate_file_truncate_width'
            end
          '';
        };
        preview = {
          on_buf.__raw = ''
            function(self)
                self:execute 'calculate_file_truncate_width'
            end
          '';
          on_close.__raw = ''
            function(self)
                self:execute 'calculate_file_truncate_width'
            end
          '';
        };
      };
      layouts = {
        select = {
          layout = {
            relative = "cursor";
            width = 70;
            min_width = 0;
            row = 1;
          };
        };
      };
    };
  };
}
