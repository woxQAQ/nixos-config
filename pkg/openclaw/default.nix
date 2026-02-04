{ openclaw-pkg, ... }:
{
  programs.openclaw = {
    documents = ./documents;
    # Use openclaw-gateway instead of full openclaw to avoid bundled tool conflicts
    package = openclaw-pkg.openclaw-gateway;
    instances.default = {
      enable = true;
      # Schema-typed Openclaw config (from upstream)
      config = {
        gateway = {
          mode = "local";
        };
      };
    };
  };
}
