{
  nixos-core-module,
  pkgs,
  ...
}: {
  imports = [nixos-core-module];

  system.nixos-core = {
    enable = true;
    components = {
      # defaulty tych trzech czytają usunięte boot.initrd.systemd.enable; jawna wartość ich nie liczy
      extraUtilsCommand.enable = false;
      bootStage1.enable = false;
      initialRamdisk.enable = false;
      bootStage2.enable = false;
      etcActivation.enable = false;
      userGroupsActivation.enable = false;
      nixosInitCompat.enable = false;
    };
    persistence = {
      enable = true;
      stores."/persist".directories = [
        "/var/lib/systemd/timers"
        "/var/log/journal"
      ];
    };
  };

  services.journald.settings.Journal.Storage = "persistent";

  boot.kernelParams = ["systemd.machine_id=firmware"];
  systemd.suppressedSystemUnits = ["systemd-machine-id-commit.service"];
  systemd.services.systemd-journal-flush = {
    after = ["nixos-core-persistence.service"];
    wants = ["nixos-core-persistence.service"];
  };

  boot.initrd.systemd.services.rollback-root = {
    description = "Rollback btrfs @root do @root-blank";
    wantedBy = ["initrd.target"];
    requires = ["dev-disk-by\\x2dlabel-nixos.device"];
    after = ["dev-disk-by\\x2dlabel-nixos.device"];
    before = ["sysroot.mount"];
    unitConfig.DefaultDependencies = "no";
    serviceConfig.Type = "oneshot";
    path = [pkgs.btrfs-progs pkgs.coreutils pkgs.findutils pkgs.util-linux];
    script = ''
      mkdir -p /btrfs
      mount -t btrfs -o subvol=/ /dev/disk/by-label/nixos /btrfs

      if [ -e /btrfs/@root ]; then
        mkdir -p /btrfs/@root-old
        stamp=$(date --date="@$(stat -c %Y /btrfs/@root)" +%Y-%m-%d_%H%M%S)
        mv /btrfs/@root "/btrfs/@root-old/$stamp"
      fi

      find /btrfs/@root-old -mindepth 1 -maxdepth 1 -mtime +14 \
        -exec btrfs subvolume delete --recursive {} +

      btrfs subvolume snapshot /btrfs/@root-blank /btrfs/@root
      umount /btrfs
    '';
  };
}
