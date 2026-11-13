# nixfiles

NixOS flake and dotfiles for two machines. `$HOME` is managed by [hjem](https://github.com/feel-co/hjem), not Home Manager.

| Host | Hardware | Traits |
|---|---|---|
| `pc` | x86_64 desktop, NVIDIA, [CachyOS kernel](https://github.com/xddxdd/nix-cachyos-kernel) | `graphical` `workstation` `gaming` |
| `laptop` | MacBook Air M2, [Asahi](https://github.com/nix-community/nixos-apple-silicon) | `graphical` `workstation` |

## Highlights

- **Ephemeral root**: an initrd service resets btrfs `@root` from `@root-blank` on every boot and keeps old roots in `@root-old` for 14 days. Only `@nix`, `@home`, `@persist` and `@nixos-state` survive; system state goes to `/persist` through `persist.directories` bind mounts.
- **Desktop**: [niri](https://github.com/barrulus/biri) (biri fork) under uwsm, greetd + tuigreet, Quickshell shell from a separate repo (`~/projects/quickshell-dynamic-island`).
- **Shell**: nushell with atuin, zoxide and carapace; sudo-rs instead of sudo.
- **Live dotfiles**: `config/` and `bin/` are symlinked to the repo checkout, not the store, so edits apply without a rebuild.
- **Two-machine sync**: Mutagen daemon; `mutagen-sessions` creates the sync sessions. `.git/index` stays per machine, so a global pre-commit hook (`bin/git-stale-index`) refuses to commit from an index older than a HEAD moved by the other machine.

## Layout

```
hosts/<host>/        hardware, disks, per-host files (niri outputs, wallpapers)
system/              base for every host: Nix, boot, users, shell, persistence
features/<trait>/    modules enabled by the host's traits
config/              app configs linked into ~/.config (config/claude -> ~/.claude)
bin/                 scripts linked into ~/.local/bin
lib/                 mkHost and the dotfiles link helpers
```

`mkHost` imports every `.nix` file under `hosts/<host>/`, `system/` and each trait's `features/<trait>/`; there are no import lists.

## Usage

The repo must live at `~/projects/nixfiles`: the link helpers and `programs.nh.flake` point there.

```sh
nh os switch                                  # rebuild and switch
nh os build                                   # build only
nix fmt                                       # alejandra
nix build .#packages.aarch64-linux.installer  # Asahi installer from the same pins
```

Run `git add` on a new file in `config/` or `bin/` before rebuilding: the flake sees only tracked files, and a missing link target fails evaluation.

## Fresh install

Not created by the config:

- btrfs labelled `nixos` with subvolumes `@root`, `@root-blank`, `@nix`, `@home`, `@persist`, `@nixos-state`
- password hash for `m` in `/persist/secrets/m.passwd` (users are immutable, root is locked)
- `laptop` only: `/persist/etc/machine-id` (`pc` derives it from the DMI UUID). Without it `rollback-root` skips the restore and the laptop gets a new machine-id on every boot. After the first boot:

  ```sh
  sudo install -d -m 0755 /persist/etc
  sudo install -m 0444 /etc/machine-id /persist/etc/machine-id
  ```
