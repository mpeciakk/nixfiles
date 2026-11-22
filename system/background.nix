{
  # no IOWeight: with the NVMe scheduler "none" io.weight does nothing (it needs BFQ or iocost)
  systemd.slices.background.sliceConfig = {
    CPUWeight = "idle";
  };

  systemd.services = {
    nix-gc.serviceConfig.Slice = "background.slice";
    "btrfs-scrub@".serviceConfig.Slice = "background.slice";
  };
}
