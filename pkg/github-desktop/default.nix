{
  github-desktop,
  lib,
  electron,
  makeShellWrapper,
}:
/*
  Repairs two defects in the nixpkgs package that break browser sign-in and
  degrade Wayland behaviour:

  1. The OAuth callback (`x-github-desktop-dev-auth://`) is silently dropped.
     Upstream registers the scheme through a .desktop entry, so the URL arrives
     as a plain argv element, but the released 3.6.x main process only reads
     `--cli-open`/`--cli-clone`; `app.on('open-url')` is macOS-only because
     Electron never emits it on Linux. The Linux branch landed upstream after
     3.6.12-beta2 and is not in a release yet.

  2. `makeWrapper` expands to a C wrapper that does not evaluate `--add-flags`
     through a shell, leaving the `${NIXOS_OZONE_WL:+...}` snippet verbatim in
     argv. The nested expansion therefore never happens and
     `--ozone-platform-hint` / `--enable-wayland-ime` never apply.
     `makeShellWrapper` emits a shell launcher where the same snippet expands
     per launch.

  The main.js edit is skipped when upstream already carries the fix, so this
  override degrades to just the wrapper change once nixpkgs catches up.
*/
github-desktop.overrideAttrs (old: {
  # `makeShellWrapper` is defined by a setup hook, so it has to enter the build
  # closure. Only `makeBinaryWrapper` ships with the package by default, which
  # is why the launcher currently freezes the Wayland snippet into argv.
  nativeBuildInputs = (old.nativeBuildInputs or [ ]) ++ [ makeShellWrapper ];

  # Rewritten rather than patched because the change is a single token inside an
  # installPhase that is otherwise stable.
  #
  # `python3` is already part of nixpkgs' nativeBuildInputs, so the patch run
  # below does not extend the closure any further.
  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/github-desktop

    # Transpose [name][size] into [size][name].
    for icon in app/static/logos/*.png; do
      size="$(basename "$icon" .png)"
      install -Dm444 "$icon" -T "$out/share/icons/hicolor/$size/github-desktop.png"
    done

    cp -r dist/*/resources $out/share/github-desktop

    # Sign-in cannot complete until the Linux protocol branch exists.
    chmod u+w $out/share/github-desktop/resources/app/main.js
    python3 ${./patch-linux-protocol.py} $out/share/github-desktop/resources/app/main.js

    makeShellWrapper ${lib.getExe electron} $out/bin/github-desktop \
      --add-flag $out/share/github-desktop/resources/app \
      --add-flags "\''${NIXOS_OZONE_WL:+\''${WAYLAND_DISPLAY:+--ozone-platform-hint=auto --enable-features=WaylandWindowDecorations --enable-wayland-ime=true}}" \
      --inherit-argv0

    mkdir -p $out/share/icons/hicolor/512x512/apps
    ln -s $out/share/github-desktop/resources/app/static/icon-logo.png $out/share/icons/hicolor/512x512/apps/github-desktop.png

    runHook postInstall
  '';
})
