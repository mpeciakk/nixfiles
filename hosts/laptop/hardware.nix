{
  inputs,
  lib,
  ...
}: {
  imports = [inputs.nixos-apple-silicon.nixosModules.apple-silicon-support];

  hardware.asahi.enable = true;
  hardware.asahi.peripheralFirmwareDirectory = null;

  # Asahi ESP is only ~500 MB
  boot.loader.systemd-boot.configurationLimit = lib.mkForce 3;
  boot.loader.systemd-boot.editor = false;

  boot.kernelParams = ["appledrm.show_notch=1"];

  fileSystems = {
    # Asahi installer's ESP has no label; its UUID survives reinstalls
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
