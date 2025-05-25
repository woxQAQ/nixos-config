{
  avante = {
    enable = true;
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
