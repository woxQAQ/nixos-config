{
  pkgs,
  nur-ryan4yin,
  ...
}:
{
  home.file.".local/share/fcitx5/themes".source = "${nur-ryan4yin.packages.${pkgs.system}.catppuccin-fcitx5}/src";
  
  # Rime 配置文件
  xdg.configFile = {
    # fcitx5 配置
    "fcitx5/profile" = {
      source = ./profile.conf;
      force = true;
    };
    "fcitx5/conf/classicui.conf".source = ./class.conf;

    # Rime 配置
    "fcitx5/rime/default.custom.yaml" = {
      text = ''
        __patch:
          menu:
            page_size: 9
          schema_list:
            - schema: luna_pinyin_simp
          ascii_composer:
            good_old_caps_lock: false
            switch_key:
              Shift_L: noop
              Shift_R: noop
              Control_L: noop
              Control_R: noop
              Caps_Lock: clear
      '';
      onChange = "rm -rf ~/.local/share/fcitx5/rime/build";
    };

    # 简体中文配置
    "fcitx5/rime/luna_pinyin_simp.custom.yaml" = {
      text = ''
        __patch:
          switches:
            - name: ascii_mode
              reset: 0
              states: ["中文", "西文"]
            - name: full_shape
              states: ["半角", "全角"]
            - name: simplification
              reset: 1
              states: ["漢字", "汉字"]
          # 设置默认为简体
          switches/@0/reset: 0      # 默认中文
          switches/@1/reset: 0      # 默认半角
          switches/@2/reset: 1      # 默认简体
      '';
      onChange = "rm -rf ~/.local/share/fcitx5/rime/build";
    };
  };

  i18n.inputMethod = {
    enabled = "fcitx5";
    fcitx5.addons = with pkgs; [
      fcitx5-rime
      fcitx5-configtool
      fcitx5-chinese-addons
      fcitx5-gtk
    ];
  };
}
