{inputs, ...}: {
  unstable-packages = final: _prev: {
    master = import inputs.master {
      inherit (final) system;
      config.allowUnfree = true;
      overlays = [
        (_final: _prev: {
          # example = prev.example.overrideAttrs (oldAttrs: rec {
          # ...
          # });
        })
      ];
    };
    unstable = import inputs.unstable {
      inherit (final) system;
      config.allowUnfree = true;
      overlays = [
        (_final: _prev: {
          # example = prev.example.overrideAttrs (oldAttrs: rec {
          # ...
          # });
        })
      ];
    };
  };

  # 自定义包 overlay
  modifications = final: prev: {
    git-status = final.callPackage ../pkg/git-status {};
    gemini-cli = final.callPackage ../pkg/gemini-cli {};
  };
}
