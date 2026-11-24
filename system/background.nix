{
  # no IOWeight: neither "none" (pc) nor mq-deadline (laptop) implements io.weight (it needs BFQ or iocost)
  systemd.slices.background.sliceConfig = {
    CPUWeight = "idle";
  };

  systemd.services = {
    nix-gc.serviceConfig.Slice = "background.slice";
    "btrfs-scrub@".serviceConfig.Slice = "background.slice";
  };
}
