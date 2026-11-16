{
  config,
  inputs,
  lib,
  pkgs,
  ...
}: {
  imports = [inputs.nixos-apple-silicon.nixosModules.apple-silicon-support];

  hardware.asahi.enable = true;
  hardware.asahi.peripheralFirmwareDirectory = null;

  # fairydust: DP alt mode (monitor przez USB-C); tag asahi-* tego nie ma
  # linux-asahi.override nie przyjmuje src (brak `...`), więc podmiana idzie przez buildLinux
  boot.kernelPackages = let
    asahiPkgs = config.hardware.asahi.pkgs;
    base = asahiPkgs.linux-asahi.override {_kernelPatches = config.boot.kernelPatches;};
    kernel = base.kernel.override {
      buildLinux = args:
        asahiPkgs.buildLinux (args
          // {
            version = "7.2.15-fairydust";
            modDirVersion = "7.2.15";
            src = pkgs.fetchFromGitHub {
              owner = "AsahiLinux";
              repo = "linux";
              rev = "432e09dca5d88e145eba6ff6080cd77aa5b8ccf8"; # fairydust @ 2026-11-05
              hash = "sha256-oB40IG6UgwgklAO8J09KY8/FPzF5nklvKvZe8A2/2Pg=";
            };
          });
    };
  in
    lib.mkForce (asahiPkgs.linuxPackagesFor kernel);

  # backport z 7.3: glibc 2.44 używa __u128, tools/ w 7.2 go nie znają; usunąć po wyjściu z fairydust 7.2
  boot.kernelPatches = [
    {
      name = "tools-u128";
      patch = ./patches/tools-u128.patch;
    }
  ];

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

  # Quickshell's battery indicator (services/Battery.qml) reads UPower
  services.upower.enable = true;

  persist.directories = {
    "/etc/NetworkManager/system-connections" = "0700";
    "/var/lib/iwd" = "0700";
    "/var/lib/bluetooth" = "0700";
    "/var/lib/NetworkManager" = "0755";
    "/var/lib/systemd/backlight" = "0755";
  };
}
