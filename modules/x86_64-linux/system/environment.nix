{
  pkgs,
  username,
  ...
}:
{
  environment.systemPackages = with pkgs; [
    (writeShellScriptBin "python" ''
      export LD_LIBRARY_PATH=$NIX_LD_LIBRARY_PATH
      exec ${python3}/bin/python "$@"
    '')
  ];
  nix.settings.trusted-users = [ username ];

  # environment.variables.EDITOR = lib.mkForce "vim";
}
