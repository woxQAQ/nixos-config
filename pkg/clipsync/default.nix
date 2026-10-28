{
  lib,
  buildGoModule,
  makeWrapper,
  wl-clipboard,
  xclip,
  clipnotify,
}:
buildGoModule {
  pname = "clipsync";
  version = "0.1.0";
  src = ./.;

  # stdlib only, no external Go modules.
  vendorHash = null;

  nativeBuildInputs = [ makeWrapper ];

  # The daemon shells out to wl-copy/wl-paste, xclip and clipnotify at
  # runtime; pin them into the wrapper's PATH so the systemd unit needs no
  # extra environment.
  postInstall = ''
    wrapProgram $out/bin/clipsync \
      --prefix PATH : ${
        lib.makeBinPath [
          wl-clipboard
          xclip
          clipnotify
        ]
      }
  '';

  meta = {
    description = "Wayland <-> X11 clipboard sync daemon for xwayland-satellite setups";
    longDescription = ''
      Bridges the X11 CLIPBOARD selection and the Wayland data device for
      compositors that run X11 apps through xwayland-satellite (niri,
      Hyprland, ...), where the satellite's own bridge is incomplete.
      Orchestrates xclip, clipnotify and wl-clipboard. Go port of
      https://github.com/ryan4yin/pyclipsync.
    '';
    license = lib.licenses.mit;
    platforms = lib.platforms.linux;
    mainProgram = "clipsync";
  };
}
