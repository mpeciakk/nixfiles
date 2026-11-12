{
  zramSwap = {
    enable = true;
    memoryMax = 8 * 1024 * 1024 * 1024;
    priority = 100;
  };

  boot.kernelParams = ["zswap.enabled=0"];
  boot.kernel.sysctl = {
    "vm.swappiness" = 150;
    "vm.vfs_cache_pressure" = 50;
    "vm.dirty_bytes" = 268435456;
    "vm.dirty_background_bytes" = 67108864;
  };

  services.btrfs.autoScrub = {
    enable = true;
    interval = "monthly";
    fileSystems = ["/nix"];
  };
}
