{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  eigen,
  onnxruntime,
  opencv,
}:

stdenv.mkDerivation {
  pname = "fastdeploy-ppocr";
  version = "1.0.7-unstable-2026-09-18";

  # Stripped-down FastDeploy maintained by the Maa organization, pinned to the
  # revision MaaDeps' vcpkg port (maa-fastdeploy) builds against.
  src = fetchFromGitHub {
    owner = "MaaXYZ";
    repo = "FastDeploy";
    rev = "e11935e4595360e7038573db1a7ab08dd0e096ec";
    hash = "sha256-7g0T5TZ2M2I12nIq9Cytbi8qGw60ssxAgYr2o1pAUVU=";
  };

  nativeBuildInputs = [ cmake ];

  # The fork ships a pre-generated config.h that hardcodes WITH_COREML, while
  # nixpkgs' onnxruntime ships coreml_provider_factory.h without exporting the
  # corresponding function on Linux; the CoreML call would compile in and fail
  # at dlopen time. CoreML is Apple-only anyway.
  postPatch = ''
    substituteInPlace fastdeploy/core/config.h \
      --replace-fail "#define WITH_COREML" "/* #undef WITH_COREML */"
  '';

  buildInputs = [
    eigen
    onnxruntime
    opencv
  ];

  cmakeBuildType = "None";

  cmakeFlags = [
    (lib.cmakeBool "BUILD_SHARED_LIBS" true)
    # The bundled Findonnxruntime.cmake looks up onnxruntime via find_library,
    # which cannot see our split outputs; point it at the store paths.
    (lib.cmakeFeature "onnxruntime_INCLUDE_DIR" "${lib.getDev onnxruntime}/include")
    (lib.cmakeFeature "onnxruntime_LIBRARY" "${lib.getLib onnxruntime}/lib/libonnxruntime.so")
  ];

  meta = {
    description = "MaaAssistantArknights stripped-down version of FastDeploy (PP-OCR only)";
    homepage = "https://github.com/MaaXYZ/FastDeploy";
    license = lib.licenses.asl20;
    platforms = lib.platforms.linux;
  };
}
