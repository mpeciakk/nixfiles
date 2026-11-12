{
  inputs,
  lib,
  ...
}: {
  imports = [inputs.nixos-apple-silicon.nixosModules.apple-silicon-support];

  hardware.asahi.enable = true;
  hardware.asahi.peripheralFirmwareDirectory = null;

  # m1n1/U-Boot nie mają zmiennych EFI; ESP Asahi ma ~500 MB
  boot.loader.efi.canTouchEfiVariables = lib.mkForce false;
  boot.loader.systemd-boot.configurationLimit = lib.mkForce 3;
  # lutowany dysk bez LUKS: init=/bin/sh z menu boota to najtańsza droga złodzieja do danych
  boot.loader.systemd-boot.editor = false;

  boot.kernelParams = ["appledrm.show_notch=1"];

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
    # ESP z instalatora Asahi nie ma labelu; zostaje przy reinstalu
    "/boot" = {
      device = "/dev/disk/by-uuid/2597-F992";
      fsType = "vfat";
      options = ["fmask=0077" "dmask=0077"];
    };
  };

  networking.networkmanager = {
    enable = true;
    wifi.backend = "iwd";
  };
  users.users.m.extraGroups = ["networkmanager"];

  hardware.bluetooth.enable = true;

  persist.directories = {
    "/etc/NetworkManager/system-connections" = "0700";
    "/var/lib/iwd" = "0700";
    "/var/lib/bluetooth" = "0700";
  };
}
