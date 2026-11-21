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
    # per-link DNS, so the tunnel can own just *.local.peciak.xyz
    dns = "systemd-resolved";
  };
  services.resolved.enable = true;
  users.users.m.extraGroups = ["networkmanager"];

  # Split tunnel to the home LAN via the WireGuard hub on sirius (~/projects/cloud, "Dostęp zdalny").
  # No autostart: on home Wi-Fi the laptop is itself in 192.168.1.0/24 and the tunnel would take that route.
  # Of 192.168.0.0/24 only AdGuard (.106) and NPM (.108): the whole /24 collides with too many foreign networks.
  # Split DNS: only *.local.peciak.xyz goes to AdGuard, everything else stays on the local link.
  networking.wg-quick.interfaces.wg0 = {
    address = ["10.99.0.3/32"];
    privateKeyFile = "/persist/etc/wireguard/wg0.key";
    autostart = false;
    # the path to the home LAN carries at most 1392-byte inner packets (ping -M do); at 1420 TLS handshakes stall
    mtu = 1380;
    postUp = [
      "${pkgs.systemd}/bin/resolvectl dns wg0 192.168.0.106"
      "${pkgs.systemd}/bin/resolvectl domain wg0 '~local.peciak.xyz'"
      "${pkgs.systemd}/bin/resolvectl default-route wg0 false"
    ];
    peers = [
      {
        publicKey = "UU0IJZvVAopjk6CQeY10LgE5nO4IRht/t3rwAS4r5zo="; # hub sirius
        endpoint = "vpn.peciak.xyz:51820";
        allowedIPs = ["10.99.0.0/24" "192.168.1.0/24" "192.168.0.106/32" "192.168.0.108/32"];
        persistentKeepalive = 25;
      }
    ];
  };

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
