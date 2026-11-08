{pkgs, ...}: {
  programs.gamemode.enable = true;
  programs.gamescope.enable = true;
  environment.systemPackages = [pkgs.mangohud];
  users.users.m.extraGroups = ["gamemode"];
}
