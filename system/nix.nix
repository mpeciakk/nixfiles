{
  config,
  inputs,
  ...
}: {
  nixpkgs.config.allowUnfree = true;
  system.stateVersion = "26.11";

  nix = {
    channel.enable = false;
    nixPath = ["nixpkgs=${inputs.nixpkgs}"];
    registry.nixpkgs.flake = inputs.nixpkgs;

    settings = {
      experimental-features = ["nix-command" "flakes"];
      use-xdg-base-directories = true;
      auto-optimise-store = true;
      warn-dirty = false;
    };

    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 14d";
    };
  };

  programs.nh = {
    enable = true;
    flake = "/home/m/projects/nixfiles";
  };
  # programs.nh sets it only in /etc/set-environment, which a nushell TTY login never reads
  environment.sessionVariables.NH_FLAKE = config.programs.nh.flake;
}
