# nixfiles

Konfiguracja NixOS i dotfiles dwóch maszyn: `pc` (x86_64, NVIDIA) i `laptop` (MacBook Air M2, Asahi). Jeden flake, `$HOME` zarządza [hjem](https://github.com/feel-co/hjem).

## Układ

| Katalog | Co trzyma |
|---|---|
| `hosts/<host>/` | sprzęt, dyski, kernel i to, co zależy od maszyny (np. monitory w `files.nix`) |
| `system/` | wspólna baza każdego hosta: Nix, boot, użytkownik, powłoka |
| `features/<trait>/` | moduły włączane listą traitów hosta: `workstation`, `graphical`, `gaming` |
| `config/` | configi aplikacji (niri, nushell, kitty, nvim, herdr…), linkowane do `~/.config/<aplikacja>`; wyjątek: `config/claude` idzie do `~/.claude` |
| `bin/` | skrypty linkowane do `~/.local/bin` |
| `lib/` | `mkHost` i helpery linkowania (`lib/dotfiles.nix`) |

Shell Quickshell (Wyspa) leży w osobnym repo `quickshell-dynamic-island`.

## Jak działają linki

Pliki z `config/` i `bin/` hjem linkuje poza store'em, do repo w `~/projects/nixfiles`. Edycja działa od razu, bez rebuildu. Istnienie każdego linkowanego pliku sprawdza ewaluacja, więc brakujący plik zatrzymuje build, zanim zepsuje aktywację. Nowy plik musi być dodany do gita (`git add`), bo flake widzi tylko pliki śledzone.

## Rebuild

```sh
nh os switch            # ścieżkę flake'a zna z programs.nh.flake
nh os build             # sam build, bez przełączania
```
