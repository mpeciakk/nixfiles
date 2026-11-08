{
  description = "NixOS: pc i laptop";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    hjem = {
      url = "github:feel-co/hjem";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-core.url = "github:manic-systems/nixos-core";

    nix-cachyos-kernel.url = "github:xddxdd/nix-cachyos-kernel/release";

    biri = {
      url = "github:barrulus/biri";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    helium = {
      url = "github:oxcl/nix-flake-helium-browser";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs: let
    mylib = import ./lib {inherit inputs;};
  in {
    nixosConfigurations = import ./hosts {inherit mylib;};
    formatter.x86_64-linux = inputs.nixpkgs.legacyPackages.x86_64-linux.alejandra;
  };
}
