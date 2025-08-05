{
  autoCmd = [
    {
      event = "FileType";
      pattern = "helm";
      command = "LspRestart";
    }
  ];
  lsp.servers.helm_ls.enable = true;
}
