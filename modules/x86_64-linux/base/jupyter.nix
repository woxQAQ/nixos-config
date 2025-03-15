{pkgs, ...}: {
  services.jupyter = {
    enable = false;
    port = 9888;
    password = "123456";
    extraPackages = [
      (
        pkgs.python3.withPackages (python-pkgs:
          with python-pkgs; [
            langchain
            python312Packages.langchain-openai
          ])
      )
    ];
  };
}
