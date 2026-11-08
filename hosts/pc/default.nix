{lib, ...}: {
  # hostname = nazwa maszyny w vaulcie (`pc`, `laptop`)
  networking.hostName = "pc";

  # wersja z chwili instalacji; nie podnosić przy aktualizacjach
  system.stateVersion = "26.11";

  # build-vm: bez NVIDII, bez pliku z hasłem, bez rollbacku (VM ma własny dysk)
  virtualisation.vmVariant = {
    services.xserver.videoDrivers = lib.mkForce ["modesetting"];
    hardware.nvidia.modesetting.enable = lib.mkForce false;
    users.users.m = {
      hashedPasswordFile = lib.mkForce null;
      initialPassword = "test";
    };
    boot.initrd.systemd.services.rollback-root.enable = false;
    # VM nie ma osobnego /persist
    system.nixos-core.persistence.enable = lib.mkForce false;
    virtualisation = {
      memorySize = 4096;
      cores = 4;
      # źródła symlinków hjem poza store muszą istnieć przy aktywacji
      sharedDirectories.dotfiles = {
        source = "/home/m/dotfiles";
        target = "/home/m/dotfiles";
      };
    };
  };
}
