{
  config,
  inputs,
  pkgs,
  ...
}: {
  nixpkgs.overlays = [inputs.nix-cachyos-kernel.overlays.pinned];
  boot.kernelPackages = pkgs.cachyosKernels.linuxPackages-cachyos-bore-lto-x86_64-v3;
  nix.settings = {
    extra-substituters = ["https://cache.lantian.pub/lantian"];
    extra-trusted-public-keys = ["lantian:WVGO7vsRMSEN+h7Lp7kv6SAmrkEXgUGbbXm7jMDjBuQ="];
  };

  boot.initrd.availableKernelModules = ["nvme" "xhci_pci" "ahci" "usbhid" "sd_mod"];
  boot.kernelModules = ["kvm-intel"];
  hardware.cpu.intel.updateMicrocode = true;
  hardware.enableRedistributableFirmware = true;

  fileSystems = let
    btrfs = subvol: {
      device = "/dev/disk/by-label/nixos";
      fsType = "btrfs";
      options = ["subvol=${subvol}" "compress=zstd:3" "noatime"];
    };
  in {
    "/" = btrfs "@root";
    "/nix" = btrfs "@nix";
    "/persist" = btrfs "@persist" // {neededForBoot = true;};
    "/var/lib/nixos" = btrfs "@nixos-state" // {neededForBoot = true;};
    "/home" = btrfs "@home" // {neededForBoot = true;};
    "/boot" = {
      device = "/dev/disk/by-label/BOOT";
      fsType = "vfat";
      options = ["fmask=0077" "dmask=0077"];
    };
    "/mnt/backup" = {
      device = "/dev/disk/by-label/backup";
      fsType = "btrfs";
      options = ["nofail" "x-systemd.automount" "noatime" "compress=zstd:3"];
    };
  };
  # dopisane do /nix z system/memory.nix: osobny btrfs, bitrot w backupie wyszedłby dopiero przy odtwarzaniu
  services.btrfs.autoScrub.fileSystems = ["/mnt/backup"];

  services.xserver.videoDrivers = ["nvidia"];
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };
  hardware.nvidia = {
    open = true;
    modesetting.enable = true;
    package = config.boot.kernelPackages.nvidiaPackages.latest;
  };
  environment.sessionVariables = {
    __GL_SHADER_DISK_CACHE_SIZE = "12000000000";
    LIBVA_DRIVER_NAME = "nvidia";
    __GLX_VENDOR_LIBRARY_NAME = "nvidia";
    GBM_BACKEND = "nvidia-drm";
    NVD_BACKEND = "direct";
    VDPAU_DRIVER = "nvidia";
  };
  boot.extraModprobeConfig = ''
    options nvidia NVreg_InitializeSystemMemoryAllocations=0 NVreg_DynamicPowerManagement=0x02
  '';
  boot.blacklistedKernelModules = ["ucsi_ccg"];
}
