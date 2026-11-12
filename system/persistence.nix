{
  config,
  lib,
  pkgs,
  ...
}: {
  # katalog -> tryb nadawany tylko przy pierwszym utworzeniu w /persist (istniejący zostaje, np. journal 2755 z tmpfiles)
  options.persist.directories = lib.mkOption {
    type = lib.types.attrsOf lib.types.str;
    default = {};
  };

  config = {
    persist.directories = {
      "/var/lib/systemd/timers" = "0755";
      "/var/log/journal" = "0755";
      # manifest hjem: bez niego każdy boot to aktywacja "first", która nie usuwa linków wyrzuconych z configu
      "/var/lib/hjem" = "0755";
    };

    # układ subwolumenów obu hostów; rollback-root niżej zakłada label nixos i @root
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

    # bind bez źródła wywala local-fs.target, a root ma hasło "!"; aktywacja przy boocie idzie w initrd, przed montowaniem
    system.activationScripts.persist-dirs.text = lib.concatStrings (lib.mapAttrsToList (dir: mode: ''
        mkdir -p -m ${mode} /persist${dir}
      '')
      config.persist.directories);

    services.journald.settings.Journal.Storage = "persistent";

    boot.kernelParams = ["systemd.machine_id=firmware"];
    systemd.suppressedSystemUnits = ["systemd-machine-id-commit.service"];

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

        # nowy root powstaje obok starego: nieudany snapshot (ENOSPC, brak @root-blank) zostawia działający @root
        # resztka po przerwanym boocie musi zniknąć, bo snapshot do istniejącego katalogu ląduje w nim jako podkatalog
        if [ -e /btrfs/@root-new ]; then
          btrfs subvolume delete --recursive /btrfs/@root-new
        fi
        btrfs subvolume snapshot /btrfs/@root-blank /btrfs/@root-new

        if [ -e /btrfs/@root ]; then
          mkdir -p /btrfs/@root-old
          stamp=$(date --date="@$(stat -c %Y /btrfs/@root)" +%Y-%m-%d_%H%M%S)
          mv /btrfs/@root "/btrfs/@root-old/$stamp"
          # mv zostawia mtime z bootu tego roota, a po nim liczy się 14 dni: bez touch po długim uptime archiwum znikałoby od razu
          touch "/btrfs/@root-old/$stamp" || true
        fi
        mv /btrfs/@root-new /btrfs/@root

        # sprzątanie na końcu: nieudane kasowanie archiwum nie może zostawić systemu bez @root
        find /btrfs/@root-old -mindepth 1 -maxdepth 1 -mtime +14 \
          -exec btrfs subvolume delete --recursive {} +
        umount /btrfs
      '';
    };
  };
}
