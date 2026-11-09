{
  inputs,
  pkgs,
  ...
}: {
  hjem.users.m.packages = [
    (inputs.helium.packages.${pkgs.stdenv.hostPlatform.system}.default.overrideAttrs (old: {
      # flake ma hash .deb tylko dla amd64; poprawka czeka w upstreamie (PR #7)
      src = pkgs.fetchurl {
        inherit (old.src) url;
        hash = "sha256-YTv/HS0yQBHiJTVioD9IYlDEmitcJKUQSIlVezGgcIM=";
      };
    }))
  ];
}
