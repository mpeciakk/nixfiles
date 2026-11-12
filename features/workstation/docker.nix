{
  virtualisation.docker.enable = true;
  users.users.m.extraGroups = ["docker"];
  persist.directories."/var/lib/docker" = "0710";
}
