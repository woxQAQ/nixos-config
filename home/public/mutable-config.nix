{ lib, dotfilesDir, ... }:
{
  # Out-of-store symlinks created via mylib.mkMutable cannot be validated
  # during pure evaluation (absolute paths are invisible to it), so verify
  # them here at activation time: the switch fails if dotfilesDir does not
  # point at this repo's checkout, or if any symlink into it is broken.
  home.activation.checkMutableConfig =
    lib.hm.dag.entryAfter [ "linkGeneration" ]
      #sh
      ''
        if [ ! -f "${dotfilesDir}/flake.nix" ]; then
          echo "checkMutableConfig: '${dotfilesDir}' is not the nixos-config checkout." >&2
          echo "Set dotfilesDir in hosts/<hostname>/values.nix to the repo location." >&2
          exit 1
        fi
        broken=$(
          {
            if [ -d "$HOME/.config" ]; then
              find "$HOME/.config" -xtype l -lname '${dotfilesDir}/*' || true
            fi
            find "$HOME" -mindepth 1 -maxdepth 2 -xtype l -lname '${dotfilesDir}/*' || true
          } 2>/dev/null | sort -u
        )
        if [ -n "$broken" ]; then
          echo "checkMutableConfig: broken symlink(s) pointing into ${dotfilesDir}:" >&2
          echo "$broken" >&2
          exit 1
        fi
      '';
}
