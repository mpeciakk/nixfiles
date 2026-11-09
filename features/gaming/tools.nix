{pkgs, ...}: {
  programs.gamemode.enable = true;
  programs.gamescope.enable = true;
  users.users.m.extraGroups = ["gamemode"];

  hjem.users.m.packages = with pkgs; [
    mangohud
    prismlauncher
  ];
}
