{
  config,
  lib,
  pkgs,
  ...
}: {
  options.persist.directories = lib.mkOption {
    type = lib.types.attrsOf lib.types.str;
    default = {};
  };

  config = {
    persist.directories = {
      "/var/lib/systemd/timers" = "0755";
      "/var/log/journal" = "0755";
      "/var/lib/hjem" = "0755";
      "/var/lib/systemd/coredump" = "0755";
    };

    fileSystems = let
      btrfs = subvol: {
        device = "/dev/disk/by-label/nixos";
        fsType = "btrfs";
        options = ["subvol=${subvol}" "compress=zstd:3" "noatime"];
      };
    in
      {
        "/" = btrfs "@root";
        "/nix" = btrfs "@nix";
        "/persist" = btrfs "@persist" // {neededForBoot = true;};
        "/var/lib/nixos" = btrfs "@nixos-state" // {neededForBoot = true;};
        "/home" = btrfs "@home" // {neededForBoot = true;};
      }
      // lib.mapAttrs (dir: _: {
        device = "/persist${dir}";
        fsType = "none";
        options = ["bind"];
      })
      config.persist.directories;

    # mode applies only when the directory is first created: mkdir -p leaves an existing one as is
    system.activationScripts.persist-dirs.text = lib.concatStrings (lib.mapAttrsToList (dir: mode: ''
        mkdir -p -m ${mode} /persist${dir}
      '')
      config.persist.directories);

    services.journald.settings.Journal.Storage = "persistent";

    boot.initrd.systemd.services.rollback-root = {
      description = "Rollback btrfs @root do @root-blank";
      wantedBy = ["initrd.target"];
      requires = ["dev-disk-by\\x2dlabel-nixos.device"];
      after = ["dev-disk-by\\x2dlabel-nixos.device"];
      before = ["sysroot.mount"];
      unitConfig.DefaultDependencies = "no";
      serviceConfig.Type = "oneshot";
      script = ''
        mkdir -p /btrfs
        mount -t btrfs -o subvol=/ /dev/disk/by-label/nixos /btrfs

        # build next to the old root so a failed snapshot leaves @root intact
        # a snapshot into an existing dir would nest inside it
        if [ -e /btrfs/@root-new ]; then
          btrfs subvolume delete --recursive /btrfs/@root-new
        fi
        btrfs subvolume snapshot /btrfs/@root-blank /btrfs/@root-new
        # laptop has no DMI UUID, so its machine-id is kept in /persist
        if [ -e /btrfs/@persist/etc/machine-id ]; then
          install -D -m 0444 /btrfs/@persist/etc/machine-id /btrfs/@root-new/etc/machine-id
        fi

        if [ -e /btrfs/@root ]; then
          mkdir -p /btrfs/@root-old
          # initrd has no /etc/localtime, so date prints UTC; the Z keeps it from passing for local time
          stamp=$(date -u --date="@$(stat -c %Y /btrfs/@root)" +%Y-%m-%d_%H%M%SZ)
          mv /btrfs/@root "/btrfs/@root-old/$stamp"
          # mv keeps the boot-time mtime; without touch a long-uptime root would be pruned immediately
          touch "/btrfs/@root-old/$stamp" || true
        fi
        mv /btrfs/@root-new /btrfs/@root

        # prune last: a failed delete must not leave the system without @root
        ${pkgs.findutils}/bin/find /btrfs/@root-old -mindepth 1 -maxdepth 1 -mtime +14 \
          -exec btrfs subvolume delete --recursive {} +
        umount /btrfs
      '';
    };
  };
}
