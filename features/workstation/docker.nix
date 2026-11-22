{
  virtualisation.docker.enable = true;
  # docker.socket starts it on first use; containers with a restart policy no longer come up at boot
  virtualisation.docker.enableOnBoot = false;
  users.users.m.extraGroups = ["docker"];
  persist.directories."/var/lib/docker" = "0710";
}
