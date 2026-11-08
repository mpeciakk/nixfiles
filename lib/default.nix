{inputs}: let
  inherit (inputs.nixpkgs) lib;

  importDir = dir:
    if builtins.pathExists dir
    then lib.filter (lib.hasSuffix ".nix") (lib.filesystem.listFilesRecursive dir)
    else [];
in {
  mkHost = name: {
    system,
    traits ? [],
  }:
    lib.nixosSystem {
      specialArgs = {
        inherit inputs;
        nixos-core-module = let
          src = inputs.nixpkgs.legacyPackages.${system}.applyPatches {
            name = "nixos-core-patched";
            src = inputs.nixos-core;
            patches = [../patches/nixos-core-fixes.patch];
          };
        in
          import "${src}/nix/modules/nixos.nix" inputs.nixos-core;
      };
      modules =
        [{nixpkgs.hostPlatform = system;}]
        ++ importDir ../hosts/${name}
        ++ importDir ../system
        ++ lib.concatMap (trait: importDir ../features/${trait}) traits
        ++ importDir ../home;
    };
}
