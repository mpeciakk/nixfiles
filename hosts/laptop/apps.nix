{
  inputs,
  pkgs,
  ...
}: {
  hjem.users.m.packages = [
    (inputs.helium.packages.${pkgs.stdenv.hostPlatform.system}.default.overrideAttrs (old: {
      # upstream flake only has the amd64 .deb hash (fix pending: PR #7)
      src = pkgs.fetchurl {
        inherit (old.src) url;
        hash = "sha256-YTv/HS0yQBHiJTVioD9IYlDEmitcJKUQSIlVezGgcIM=";
      };
    }))
  ];
}
