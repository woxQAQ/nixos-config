{
  pkgs,
  username,
  inputs,
  system,
  ...
}:
{
  environment.systemPackages = with pkgs; [
    (writeShellScriptBin "python" ''
      export LD_LIBRARY_PATH=$NIX_LD_LIBRARY_PATH
      exec ${python3}/bin/python "$@"
    '')
    inputs.agenix.packages.${system}.default
  ];
  nix.settings.trusted-users = [ username ];

  # environment.variables.EDITOR = lib.mkForce "vim";
}
