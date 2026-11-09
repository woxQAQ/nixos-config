{
  dbeaver-bin,
  lib,
  stdenv,
  python3,
  writeText,
  drivers ? [ ],
  forceX11 ? false,
  environment ? { },
  extraJavaOptions ? [ ],
  showSplash ? true,
}:
let
  applicationDir =
    if stdenv.hostPlatform.isDarwin then
      "Applications/dbeaver.app/Contents/Eclipse"
    else
      "opt/dbeaver";
  environmentArgs = lib.concatStringsSep " " (
    lib.mapAttrsToList (
      name: value:
      lib.escapeShellArgs (
        if value == null then
          [
            "--unset"
            name
          ]
        else
          [
            "--set"
            name
            value
          ]
      )
    ) environment
  );
  driverManifest = writeText "dbeaver-jdbc-packages.json" (
    builtins.toJSON (
      map (driver: {
        name = lib.getName driver;
        directory = "${driver}/share/java";
      }) drivers
    )
  );
in
if
  drivers == [ ]
  && !(forceX11 && stdenv.hostPlatform.isLinux)
  && environment == { }
  && extraJavaOptions == [ ]
  && showSplash
then
  dbeaver-bin
else
  dbeaver-bin.overrideAttrs (old: {
    nativeBuildInputs =
      (old.nativeBuildInputs or [ ]) ++ lib.optional (drivers != [ ]) python3;

    postInstall =
      (old.postInstall or "")
      + lib.optionalString (drivers != [ ]) ''
        python ${./configure-drivers.py} \
          "$out/${applicationDir}/plugins" "$out/share/java" ${driverManifest}
      ''
      + lib.optionalString (!showSplash) ''
        substituteInPlace "$out/${applicationDir}/dbeaver.ini" \
          --replace-fail '-vmargs' ${lib.escapeShellArg "-nosplash\n-vmargs"}
      ''
      + lib.optionalString (extraJavaOptions != [ ]) ''
        printf '\n%s\n' ${lib.escapeShellArgs extraJavaOptions} >> "$out/${applicationDir}/dbeaver.ini"
      '';

    # SWT renders workbench widgets at inconsistent sizes on Wayland.
    preFixup =
      (old.preFixup or "")
      + lib.optionalString (forceX11 && stdenv.hostPlatform.isLinux) ''
        gappsWrapperArgs+=(--set GDK_BACKEND x11)
      ''
      + lib.optionalString (environment != { }) ''
        gappsWrapperArgs+=(${environmentArgs})
      '';

    # Darwin uses makeWrapper directly rather than wrapGAppsHook.
    postFixup =
      (old.postFixup or "")
      + lib.optionalString (stdenv.hostPlatform.isDarwin && environment != { }) ''
        wrapProgram "$out/Applications/dbeaver.app/Contents/MacOS/dbeaver" ${environmentArgs}
      '';
  })
