{lib,pkgs,...} : {
  home.packages = with pkgs; [
    zip unzip p7zip kitty gamescope
    repgrep yq-go jq htop go
    mpv neofetch tldr treefmt2 wl-clipboard gcc gdb obs-studio
    python3 winetricks nixd 
    graphviz xdg-utils wineWowPackages.wayland
    nodejs nodePackages.npm yarn nodePackages.pnpm
    docker-compose kubectl
  ];
  programs = {
    fzf = {
      enable = true;
    };
    tmux = {
      enable = true;
    };
    bat =  {
      enable = true;
      config ={
        paper = "less -FR";
      };
    };
    jq.enable = true;
    eza.enable = true;
  };
}
