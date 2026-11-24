{
  zramSwap = {
    enable = true;
    # zram-generator takes min(memoryPercent of RAM, memoryMax); at the default 50% the 8 GiB cap never binds on laptop
    memoryPercent = 100;
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

  # the NixOS module starts the daemon but enables no slice, so it watches nothing
  systemd.oomd.enable = false;

  services.btrfs.autoScrub = {
    enable = true;
    interval = "monthly";
    fileSystems = ["/nix"];
  };
}
