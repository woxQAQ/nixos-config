{ mkKeymap, ... }:
{
  plugins.nvim-ufo = {
    enable = true;
    settings = {
      fold_virt_text_handler = /* lua */ ''
        function(virtText, lnum, endLnum, width, truncate)
          local newVirtText = {}
          local foldedLines = endLnum - lnum
          local suffix = (" 󰁂  %d"):format(foldedLines)
          local sufWidth = vim.fn.strdisplaywidth(suffix)
          local targetWidth = width - sufWidth
          local curWidth = 0

          for _, chunk in ipairs(virtText) do
            local chunkText = chunk[1]
            local chunkWidth = vim.fn.strdisplaywidth(chunkText)
            if targetWidth > curWidth + chunkWidth then
              table.insert(newVirtText, chunk)
            else
              chunkText = truncate(chunkText, targetWidth - curWidth)
              local hlGroup = chunk[2]
              table.insert(newVirtText, { chunkText, hlGroup })
              chunkWidth = vim.fn.strdisplaywidth(chunkText)
              -- str width returned from truncate() may less than 2nd argument, need padding
              if curWidth + chunkWidth < targetWidth then
                suffix = suffix .. (" "):rep(targetWidth - curWidth - chunkWidth)
              end
              break
            end
            curWidth = curWidth + chunkWidth
          end
          local rAlignAppndx =
            math.max(math.min(vim.opt.textwidth["_value"], width - 1) - curWidth - sufWidth, 0)
          suffix = (" "):rep(rAlignAppndx) .. suffix
          table.insert(newVirtText, { suffix, "MoreMsg" })
          return newVirtText
        end
      '';
    };
  };
  keymaps = [
    (mkKeymap "n" "zR" {
      __raw = "require('ufo').openAllFolds";
    } "Open all folds")
    (mkKeymap "n" "zM" {
      __raw = "require('ufo').closeAllFolds";
    } "Close all folds")
    (mkKeymap "n" "zr" {
      __raw = "require('ufo').openFoldsExceptKinds";
    } "Fold less")
    (mkKeymap "n" "<leader>K" {
      __raw = ''
        function()
          local _ = require("ufo").peekFoldedLinesUnderCursor()
        end
      '';
    } "Preview fold maps")
  ];
}
