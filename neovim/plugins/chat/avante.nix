{unstable-pkg, ...}: {
  programs.nixvim.extraPlugins = [unstable-pkg.vimPlugins.blink-cmp-avante];
  programs.nixvim.plugins.avante = {
    enable = false;
    settings = {
      provider = "openai";
      openai = {
        endpoint = "https://aihubmix.com/v1";
        max_tokens = 4096;
        model = "gemini-2.0-flash";
        temperature = 0;
      };
    };
  };
}
