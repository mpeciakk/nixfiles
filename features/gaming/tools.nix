{pkgs, ...}: {
  programs.gamemode.enable = true;
  # GE-Proton via umu sets WINENTSYNC=1 on its own; the module has no devname alias, so nothing loads it on demand
  boot.kernelModules = ["ntsync"];
  users.users.m.extraGroups = ["gamemode"];

  hjem.users.m.packages = with pkgs; [
    lutris
    mangohud
    prismlauncher
  ];

  # stable JDK paths for Prism (instances and the global JavaPath point here); the links live in the system generation, so nix-gc keeps the JDKs
  hjem.users.m.xdg.data.files = {
    "jdks/17".source = pkgs.jdk17; # Craft to Exile 2 (Forge 1.20.1)
    "jdks/21".source = pkgs.jdk21; # Prominence II
    "jdks/25".source = pkgs.jdk25; # Prism default (global JvmArgs need JDK 24+ for UseCompactObjectHeaders)
  };
}
