{
  description = "NixOS: pc i laptop";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    hjem = {
      url = "github:feel-co/hjem";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-cachyos-kernel.url = "github:xddxdd/nix-cachyos-kernel/release";

    biri = {
      url = "github:barrulus/biri";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    helium = {
      url = "github:oxcl/nix-flake-helium-browser";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    jfsh = {
      url = "github:hacel/jfsh";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "";
    };

    nixos-apple-silicon = {
      url = "github:nix-community/nixos-apple-silicon";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs: let
    mylib = import ./lib {inherit inputs;};
  in {
    nixosConfigurations = import ./hosts {inherit mylib;};
    # installer laptopa z tych samych pinów: kernel z ISO = kernel systemu, nixos-install go nie buduje
    packages.aarch64-linux.installer = inputs.nixos-apple-silicon.packages.aarch64-linux.installer-bootstrap;
    formatter.x86_64-linux = inputs.nixpkgs.legacyPackages.x86_64-linux.alejandra;
    formatter.aarch64-linux = inputs.nixpkgs.legacyPackages.aarch64-linux.alejandra;
  };
}
