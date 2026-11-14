{
  inputs,
  lib,
  pkgs,
  ...
}: {
  hjem.users.m.packages = [
    (inputs.helium.packages.${pkgs.stdenv.hostPlatform.system}.default.overrideAttrs (old: {
      # upstream flake only has the amd64 .deb hash (fix pending: PR #7)
      # the hash is for one version; a flake update must fail here, not as a hash mismatch
      src = lib.throwIf (old.version != "0.21.1.1") "hosts/laptop/apps.nix: nowy hash arm64 helium dla ${old.version} albo usuń override, jeśli PR #7 jest w upstreamie" (pkgs.fetchurl {
        inherit (old.src) url;
        hash = "sha256-YTv/HS0yQBHiJTVioD9IYlDEmitcJKUQSIlVezGgcIM=";
      });
    }))
    pkgs.brightnessctl
  ];
}
