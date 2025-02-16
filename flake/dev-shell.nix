{
  perSystem =
    {
      config,
      pkgs,
      ...
    }:
    {
      devShells.default = pkgs.mkShell {
        name = "woxQAQ";

        shellHook = ''
          ${config.pre-commit.installationScript}
        '';

        DIRENV_LOG_FORMAT = "";

        packages = with pkgs; [
          alejandra
          deadnix
          git
          nil
          statix
        ];
      };

      formatter = pkgs.alejandra;
    };
}
