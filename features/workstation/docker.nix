{
  virtualisation.docker.enable = true;
  users.users.m.extraGroups = ["docker"];
  system.nixos-core.persistence.stores."/persist".directories = ["/var/lib/docker"];
}
