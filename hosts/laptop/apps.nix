{
  inputs,
  pkgs,
  ...
}: {
  hjem.users.m.packages = [
    inputs.helium.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];
}
