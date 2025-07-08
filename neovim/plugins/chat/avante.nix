{
  avante = {
    enable = true;
    settings = {
      provider = "openai";
      providers.openai = {
        endpoint = "https://aihubmix.com/v1";
        max_tokens = 4096;
        model = "gemini-2.0-flash";
        extra_request_body = {
          temperature = 0;
          max_tokens = 8192;
        };
      };
    };
  };
}
