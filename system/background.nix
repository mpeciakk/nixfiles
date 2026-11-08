{
  systemd.slices.background.sliceConfig = {
    CPUWeight = "idle";
    IOWeight = 1;
  };

  systemd.services = {
    nix-gc.serviceConfig.Slice = "background.slice";
    "btrfs-scrub@".serviceConfig.Slice = "background.slice";
  };
}
