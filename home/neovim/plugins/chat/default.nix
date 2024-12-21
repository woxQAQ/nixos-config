{
  programs.nixvim.plugins = {
    chatgpt = {
      enable = true;
      settings = {
        api_host_cmd = ''
          echo -n "https://api.deepseek.com/v1"
        '';
        api_key_cmd = "pass sk-2f640edda9024129990180aceb3815f0";
      };
    };
  };
}
