{inputs, ...}: {
  nixpkgs.config.allowUnfree = true;

  nix = {
    channel.enable = false;
    nixPath = ["nixpkgs=${inputs.nixpkgs}"];
    registry.nixpkgs.flake = inputs.nixpkgs;

    settings = {
      experimental-features = ["nix-command" "flakes"];
      use-xdg-base-directories = true;
      trusted-users = ["@wheel"];
      auto-optimise-store = true;
    };

    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 14d";
    };
  };

  programs.nh = {
    enable = true;
    flake = "/home/m/projects/nixos";
  };
}
