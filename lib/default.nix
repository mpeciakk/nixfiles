{inputs}: let
  inherit (inputs.nixpkgs) lib;

  importDir = dir:
    if builtins.pathExists dir
    then lib.filter (lib.hasSuffix ".nix") (lib.filesystem.listFilesRecursive dir)
    else throw "nixfiles: brak katalogu ${toString dir}";
in {
  mkHost = name: {
    system,
    traits ? [],
  }:
    lib.nixosSystem {
      specialArgs = {
        inherit inputs;
        dotfiles = import ./dotfiles.nix;
      };
      modules =
        [{nixpkgs.hostPlatform = system;}]
        ++ importDir ../hosts/${name}
        ++ importDir ../system
        ++ lib.concatMap (trait: importDir ../features/${trait}) traits;
    };
}
