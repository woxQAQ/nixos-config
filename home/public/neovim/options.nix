{ pkgs, ... }:
{
  clipboard.providers.wl-copy.enable = pkgs.stdenv.hostPlatform.isLinux;

  clipboard = {
    register = "unnamedplus";
  };
  globals = {
    mapleader = " ";
    maplocalleader = " ";
    loaded_ruby_provider = 0;
    loaded_perl_provider = 0;
    loaded_python_provider = 0;
  };
  opts = {
    number = true;
    relativenumber = true;
    cursorline = true;
    cursorcolumn = false;
    signcolumn = "yes";
    showtabline = 2;
    showmatch = true;
    winborder = "rounded";

    splitbelow = true;
    splitright = true;

    mouse = "a";

    ignorecase = true;
    incsearch = true;
    smartcase = true;

    swapfile = false;
    undofile = true;
    fileencoding = "utf-8";

    tabstop = 2;
    shiftwidth = 2;
    expandtab = true;
    smartindent = true;
    autoindent = true;
    breakindent = true;
    copyindent = true;
    preserveindent = true;
    wrap = false;
    linebreak = true;

    # foldenable = true;
    # foldcolumn = "0";
    # foldlevel = 99;
    # foldmethod = "indent";
    # foldexpr = "0";
    # foldnestmax = 10;
    # foldlevelstart = 99;

    pumheight = 10;

    clipboard = "unnamedplus";

    startofline = true;
    # smoothscroll = false;
    title = true;
    titlelen = 20;
    updatetime = 500;
    # redrawtime = 1500;
    synmaxcol = 240;
  };
}
