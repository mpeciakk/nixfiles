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
      # scrub history (btrfs scrub status)
      "/var/lib/btrfs" = "0755";
      # timesyncd moves the clock to this file's mtime before time-set.target, so timers do not fire on a reset RTC
      "/var/lib/systemd/timesync" = "0755";
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

    services.journald.settings.Journal = {
      Storage = "persistent";
      # without it the cap is 10% of the filesystem, up to 4 GiB
      SystemMaxUse = "1G";
    };

    # its only rules are btmp and wtmp, which the @root rollback wipes at every boot
    services.logrotate.enable = false;

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
          # initrd has no /etc/localtime, so date prints UTC; the Z keeps it from passing for local time.
          # The subvolume ID makes the name unique: on laptop the initrd clock starts at the same
          # date every boot, and two stamps have already landed one second apart.
          id=$(btrfs inspect-internal rootid /btrfs/@root)
          stamp=$(date -u --date="@$(stat -c %Y /btrfs/@root)" +%Y-%m-%d_%H%M%SZ)-$id
          # -T: an existing name is an error instead of a move into that archive
          mv -T /btrfs/@root "/btrfs/@root-old/$stamp"
        fi
        mv /btrfs/@root-new /btrfs/@root

        # prune last: a failed delete must not leave the system without @root.
        # Keep the 10 newest by subvolume ID (IDs only grow); age by mtime does not work on laptop,
        # whose initrd clock is the same at every boot.
        for d in /btrfs/@root-old/*; do
          # only subvolume roots (inode 256); a plain directory or a failed rootid would sort first
          [ "$(stat -c %i "$d")" = 256 ] || continue
          id=$(btrfs inspect-internal rootid "$d") || continue
          [ -n "$id" ] || continue
          printf '%s %s\n' "$id" "$d"
        done | sort -n | head -n -10 | cut -d' ' -f2- |
          while IFS= read -r d; do
            btrfs subvolume delete --recursive "$d" || true
          done
        umount /btrfs
      '';
    };
  };
}
