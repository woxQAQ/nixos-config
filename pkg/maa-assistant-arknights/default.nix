{
  lib,
  callPackage,
  stdenv,
  fetchFromGitHub,
  boost,
  cmake,
  nlohmann_json,
  onnxruntime,
  opencv,
  zlib,
}:

let
  version = "6.22.0";

  fastdeploy = callPackage ./fastdeploy-ppocr.nix { };

  # src/MaaUtils is a git submodule of MaaAssistantArknights; fetch it
  # separately so the other (irrelevant, heavy) submodules stay unfetched.
  maaUtils = fetchFromGitHub {
    owner = "MaaXYZ";
    repo = "MaaUtils";
    rev = "f093a19d07db89f2a03bf0ec50c2061a49758783";
    hash = "sha256-zu8KDAo+VuJ2O6UIAAjgn6PIEV2uQwfXWVDpzw/Oj54=";
  };
in
stdenv.mkDerivation (finalAttrs: {
  pname = "maa-assistant-arknights";
  inherit version;

  src = fetchFromGitHub {
    owner = "MaaAssistantArknights";
    repo = "MaaAssistantArknights";
    tag = "v${finalAttrs.version}";
    hash = "sha256-hWgJu5fjHfG450cRqUmh0iUIKZFb6zKZwB2gsUmZl3U=";
  };

  nativeBuildInputs = [ cmake ];

  buildInputs = [
    boost
    fastdeploy
    nlohmann_json
    onnxruntime
    opencv
    zlib
  ];

  postPatch = ''
    cp -r ${maaUtils}/. src/MaaUtils/
    chmod -R u+w src/MaaUtils/

    # MaaDeps downloads prebuilt binaries via vcpkg; we build every dependency
    # from nixpkgs instead, so cut the hard include and the runtime install.
    sed -i '/maadeps\.cmake/d' src/MaaUtils/MaaUtils.cmake
    sed -i '/maadeps_install/d' src/MaaCore/CMakeLists.txt

    # MaaCore uses SIFT/SURF and friends but upstream only declares these
    # three components, relying on MaaDeps' monolithic opencv_world; nixpkgs
    # splits opencv into per-module libraries, so declare every module used.
    sed -i 's/COMPONENTS core imgproc imgcodecs/COMPONENTS core imgproc imgcodecs features2d calib3d videoio xfeatures2d/' src/MaaUtils/MaaUtils.cmake

    # nixpkgs ships Boost without per-component CMake configs; fall back to
    # the module-mode FindBoost.
    sed -i 's/find_package(Boost REQUIRED CONFIG COMPONENTS/find_package(Boost REQUIRED COMPONENTS/' src/MaaUtils/MaaUtils.cmake

    # Boost.System is header-only upstream and nixpkgs no longer ships
    # libboost_system; link the header-only interface target instead.
    sed -i 's/COMPONENTS system regex/COMPONENTS regex/' src/MaaUtils/MaaUtils.cmake
    sed -i 's/Boost::system/Boost::boost/g' src/MaaUtils/source/CMakeLists.txt src/MaaCore/CMakeLists.txt
  '';

  cmakeBuildType = "None";

  # Upstream compiles with -Werror; newer GCCs emit warnings (e.g.
  # -Wredundant-move) that their CI toolchain does not.
  env.NIX_CFLAGS_COMPILE = "-Wno-error";

  cmakeFlags = [
    (lib.cmakeBool "INSTALL_FLATTEN" false)
    (lib.cmakeBool "INSTALL_PYTHON" true)
    (lib.cmakeBool "INSTALL_RESOURCE" true)
    # RPATH_LIBRARY bundles the toolchain's libc++ next to the binaries; nix
    # resolves runtime libraries through the wrapper-added rpaths instead.
    (lib.cmakeBool "WITH_RPATH_LIBRARY" false)
    # Skips detect_maadeps_triplet(), which lives in the removed maadeps.cmake.
    (lib.cmakeFeature "MAADEPS_TRIPLET" "maa-x64-linux")
    (lib.cmakeFeature "MAA_HASH_VERSION" "v${finalAttrs.version}")
    (lib.cmakeFeature "Boost_INCLUDE_DIR" "${lib.getDev boost}/include")
    (lib.cmakeFeature "Boost_LIBRARY_DIR" "${lib.getLib boost}/lib")
    # nixpkgs Boost lacks per-component CMake configs; force FindBoost's
    # manual search instead of delegating to the upstream BoostConfig.
    (lib.cmakeBool "Boost_NO_BOOST_CMAKE" true)
    # The bundled FindONNXRuntime.cmake expects an onnxruntime/ header prefix,
    # while nixpkgs installs the headers flat; pre-seed the cache entries.
    (lib.cmakeFeature "ONNXRuntime_INCLUDE_DIR" "${lib.getDev onnxruntime}/include")
    (lib.cmakeFeature "ONNXRuntime_LIBRARY_IMP" "${lib.getLib onnxruntime}/lib/libonnxruntime.so")
  ];

  postInstall = ''
    mkdir -p $out/share/maa-assistant-arknights
    mv $out/{Python,resource} $out/share/maa-assistant-arknights
  '';

  meta = {
    description = "Arknights assistant core library";
    homepage = "https://github.com/MaaAssistantArknights/MaaAssistantArknights";
    license = lib.licenses.agpl3Only;
    platforms = lib.platforms.linux;
  };
})
