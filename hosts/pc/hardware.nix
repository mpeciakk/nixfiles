{
  config,
  inputs,
  lib,
  pkgs,
  ...
}: {
  nixpkgs.overlays = [inputs.nix-cachyos-kernel.overlays.pinned];
  boot.kernelPackages = pkgs.cachyosKernels.linuxPackages-cachyos-bore-lto;
  nix.settings = {
    extra-substituters = ["https://cache.lantian.pub/lantian"];
    extra-trusted-public-keys = ["lantian:WVGO7vsRMSEN+h7Lp7kv6SAmrkEXgUGbbXm7jMDjBuQ="];
  };

  boot.initrd.availableKernelModules = ["nvme" "xhci_pci" "ahci" "usbhid" "sd_mod"];
  boot.kernelModules = {
    "kvm-intel" = true;
    # NixOS loads it for PS/2 keyboards; every keyboard here is USB
    atkbd = lib.mkForce false;
  };
  # stable machine-id from the DMI UUID (laptop lacks one, see rollback-root)
  # mem_profiling: allocation tagging is on by default in the CachyOS config; off as on Arch
  boot.kernelParams = ["systemd.machine_id=firmware" "sysctl.vm.mem_profiling=never"];
  hardware.cpu.intel.updateMicrocode = true;
  hardware.enableRedistributableFirmware = true;

  fileSystems = {
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
  services.btrfs.autoScrub.fileSystems = ["/mnt/backup"];
  # the backup disk idles between manual copies and the monthly scrub: standby after 10 min (-S 120 = 120 x 5 s)
  services.udev.extraRules = ''
    ACTION=="add|change", SUBSYSTEM=="block", KERNEL=="sd[a-z]", ENV{ID_MODEL}=="TOSHIBA_HDWD110", RUN+="${pkgs.hdparm}/bin/hdparm -S 120 /dev/%k"
  '';

  services.xserver.videoDrivers = ["nvidia"];
  hardware.graphics.enable32Bit = true;
  hardware.nvidia = {
    open = true;
    package = config.boot.kernelPackages.nvidiaPackages.latest;
    nvidiaSettings = false;
  };
  # the nvidia module turns acpid on (mkDefault) for X-era ACPI events; logind handles the power key
  services.acpid.enable = false;
  environment.sessionVariables = {
    __GL_SHADER_DISK_CACHE_SIZE = "12000000000";
    # libva, libvdpau and glvnd pick nvidia on their own; GBM_BACKEND stays, niri's GBM loader may read it
    GBM_BACKEND = "nvidia-drm";
  };
  boot.extraModprobeConfig = ''
    options nvidia NVreg_InitializeSystemMemoryAllocations=0
    # Keychron K8 reports Apple's vendor id; fnmode=2 makes F1-F12 primary, media under Fn
    options hid_apple fnmode=2
  '';
  boot.blacklistedKernelModules = [
    "ucsi_ccg"
    # BIOS F2 fails every WMI sensor query (12 ACPI errors per boot), then the driver gives up
    "gigabyte_wmi"
    # autoloaded by alias with nothing to drive: SOF/AVS match the PCH audio that snd_hda_intel owns,
    # the ME HDCP/PXP clients serve i915, which does not run here, i2c_nvidia_gpu only feeds ucsi_ccg,
    # the Keychron fakes Apple's vendor id, nothing sits on the parallel port
    "snd_sof_pci_intel_cnl"
    "snd_soc_avs"
    "mei_hdcp"
    "mei_pxp"
    "i2c_nvidia_gpu"
    "apple_mfi_fastcharge"
    "parport_pc"
    # Wi-Fi and Bluetooth unused: wired network, no bluetooth service; cfg80211 still came in through its nl80211 alias
    "iwlwifi"
    "cfg80211"
    "btusb"
  ];

  # fork at once, so greetd (Type=idle) stops waiting for the lease;
  # network-online.target is then reached before an address is up
  networking.dhcpcd.wait = "background";
  # same DUID and lease across boots (the @root rollback wipes /var/lib)
  persist.directories."/var/lib/dhcpcd" = "0755";

  # dhcpcd 10.3.2 segfaults in ipv6nd_expire when a Docker veth vanishes (fixed upstream in 10.5.1)
  networking.dhcpcd.denyInterfaces = ["veth*" "docker*" "br-*"];
}
