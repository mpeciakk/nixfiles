# Ladybird alpha on top of nixpkgs' ladybird snapshot; delete once nixpkgs' ladybird reaches this tag
{
  lib,
  ladybird,
  ffmpeg,
  fetchFromGitHub,
  runCommand,
  rustPlatform,
  icu78,
  pdfjs,
}: let
  # upstream bundles a patched FFmpeg; both patches from Meta/CMake/vcpkg/overlay-ports/ffmpeg at the tag
  ffmpegLadybird = ffmpeg.overrideAttrs (old: {
    patches =
      (old.patches or [])
      ++ [
        ./patches/0101-vulkan-decode-dpb-distinct-no-drm-modifiers.patch
        ./patches/0102-vulkan-av1-clear-unused-ref-frame-mvs.patch
      ];
  });

  # header-only; rev pinned in the tag's vcpkg.json
  llvmLibcHeaders =
    runCommand "llvm-libc-headers-e5416942" {
      src = fetchFromGitHub {
        owner = "llvm";
        repo = "llvm-project";
        rev = "e54169423e7ee5d8b41c2f1b6f7a59000c901ee0";
        sparseCheckout = ["libc"];
        hash = "sha256-rYvY2rTNwA3Ovy3y/hI3nTp9v8kJbhxB2gseLcZ5vWA=";
      };
    } ''
      # mirrors Meta/CMake/vcpkg/overlay-ports/llvm-libc/portfile.cmake
      cd $src/libc
      for d in hdr include shared src/__support src/string/memory_utils; do
        find "$d" -name '*.h' -exec install -Dm644 {} "$out/include/llvm-libc/{}" \;
      done
    '';
in
  # postPatch below replaces nixpkgs' wholesale, so a nixpkgs bump must stop here, not silently drop its fixes
  lib.throwIf (ladybird.version != "0-unstable-2026-11-01") "pkgs/ladybird-alpha: nixpkgs ma ladybird ${ladybird.version}; jeśli dogonił alphę, usuń ten pakiet, inaczej zsynchronizuj postPatch"
  ((ladybird.override {ffmpeg = ffmpegLadybird;}).overrideAttrs (final: old: {
    version = "2026.47.7";
    src = fetchFromGitHub {
      owner = "LadybirdBrowser";
      repo = "ladybird";
      tag = final.version;
      hash = "sha256-ZSJ6QjGA7MAR/8joe0NwkhJyWZw/ag4tOCd0+F7siAA=";
    };
    cargoDeps = rustPlatform.fetchCargoVendor {
      inherit (final) pname version src;
      hash = "sha256-fYqoQxHodl7DJMfjp3S000CF8kFSD996LTH3dKg7Dtw=";
    };
    # nixpkgs' Linux postPatch minus the ResourceFiles.cmake pdfjs hack: upstream now has FindPDFJS.cmake
    postPatch = ''
      sed -i '/iconutil/d' UI/CMakeLists.txt

      substituteInPlace Meta/CMake/rust_crate.cmake \
        --replace-fail 'set(RUSTC_TARGET_FLAGS -Dwarnings ' 'set(RUSTC_TARGET_FLAGS '

      substituteInPlace Meta/CMake/check_for_dependencies.cmake \
        --replace-fail libavcodec-ladybird libavcodec \
        --replace-fail libavutil-ladybird libavutil \
        --replace-fail libswresample-ladybird libswresample

      perl -0pi -e \
        's/find_package\(ICU 78\.[0-9]+ EXACT REQUIRED COMPONENTS data i18n uc\)/find_package(ICU ${icu78.version} EXACT REQUIRED COMPONENTS data i18n uc)/ or die "ICU dependency not found\n"' \
        Meta/CMake/check_for_dependencies.cmake

      cp -r ${pdfjs}/share/pdf.js pdfjs
      chmod -R u+w pdfjs
      patch -d pdfjs -p1 < Meta/CMake/vcpkg/overlay-ports/pdfjs/0001-ladybird-embed.patch

      substituteInPlace Meta/CMake/lagom_install_options.cmake \
        --replace-fail "\''${CMAKE_INSTALL_BINDIR}" "bin" \
        --replace-fail "\''${CMAKE_INSTALL_LIBDIR}" "lib"
    '';
    preConfigure =
      old.preConfigure
      + ''
        cmakeFlagsArray+=("-DPDFJS_DIR=$PWD/pdfjs" "-DLLVM_LIBC_INCLUDE_DIR=${llvmLibcHeaders}/include")
      '';
  }))
