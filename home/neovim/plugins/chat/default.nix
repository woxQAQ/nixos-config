{
  programs.nixvim.plugins = {
    avante = {
      enable = true;
      settings = {
        provider = "openai";
        openai = {
          endpoint = "https://api.deepseek.com/v1";
          models = "deepseek-coder";
          temperature = 0;
          max_toknes = 4096;
        };
      };
    };

  };
}
