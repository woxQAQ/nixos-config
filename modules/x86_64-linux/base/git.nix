{username,...}:{
  programs.git = {
    enable = true;
    lfs.enable = true;
    userName = username;
    userEmail = "woxqaq@gmail.com";
    extraConfig = {
      http.proxy = "http://127.0.0.1:7890";
      https.proxy = "https://127.0.0.1:7890";
    };
  };
}
