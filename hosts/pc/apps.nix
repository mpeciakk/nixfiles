{
  inputs,
  pkgs,
  ...
}: {
  hjem.users.m.packages = [
    (inputs.helium.packages.${pkgs.stdenv.hostPlatform.system}.default.override {
      flags = [
        "--enable-features=AcceleratedVideoDecodeLinuxGL,AcceleratedVideoDecodeLinuxZeroCopyGL,VaapiOnNvidiaGPUs,VaapiIgnoreDriverChecks,HeuristicMemorySaver:threshold_percent/95/threshold_mb/1000000/minimum_time_in_background/15m"
        "--enable-gpu-rasterization"
        "--enable-zero-copy"
        "--ignore-gpu-blocklist"
      ];
    })
    pkgs.pwvucontrol
  ];
}
