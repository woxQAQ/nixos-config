{
  username,
  config,
  lib,
  ...
}: {
  home.activation.removeExistingGitconfig = lib.hm.dag.entryBefore ["checkLinkTargers"] ''
    rm -f ${config.home.homeDirectory}/.gitconfig
  '';
  programs.gh = {
    enable = true;
  };

  programs.lazygit = {
    enable = true;
  };

  programs.git = {
    enable = true;
    lfs.enable = true;
    userName = username;
    userEmail = "woxqaq@gmail.com";
    extraConfig = {
      http.proxy = "http://127.0.0.1:7890";
      https.proxy = "https://127.0.0.1:7890";
    };
    includes = [
      {
        path = "${config.home.homeDirectory}/.gnupg/.gitconfig";
      }
    ];
  };
}
