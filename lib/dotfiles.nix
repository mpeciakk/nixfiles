let
  root = "/home/m/projects/nixfiles";

  # link wskazuje na żywy plik w repo (edycja bez rebuildu), a istnienie sprawdza kopia
  # w źródle flake'a: brak pliku wywala ewaluację, zamiast wywrócić aktywację hjem
  source = rel:
    if builtins.pathExists (../. + "/${rel}")
    then "${root}/${rel}"
    else throw "nixfiles: brak pliku ${rel}";

  filesUnder = rel: let
    entries = builtins.readDir (../. + "/${rel}");
  in
    builtins.concatLists (map (n:
      if entries.${n} == "directory"
      then filesUnder "${rel}/${n}"
      else ["${rel}/${n}"])
    (builtins.attrNames entries));

  configEntry = rel: {
    name = rel;
    value.source = source "config/${rel}";
  };
in {
  inherit source;

  # nazwy podkatalogów <rel> w źródle flake'a (pliki nieśledzone przez gita nie istnieją)
  subdirs = rel: let
    entries = builtins.readDir (../. + "/${rel}");
  in
    builtins.filter (n: entries.${n} == "directory") (builtins.attrNames entries);

  # xdg.config: "<dir>/<name>" -> nixfiles/config/<dir>/<name>
  link = dir: names: builtins.listToAttrs (map (n: configEntry "${dir}/${n}") names);

  # xdg.config: "<dir>" jako jeden symlink katalogu (nowe pliki widoczne bez rebuildu)
  linkDir = dir: builtins.listToAttrs [(configEntry dir)];

  # xdg.config: każdy plik z config/<dir> osobno; katalog w ~/.config zostaje prawdziwy,
  # więc to, co program dopisze obok (np. lazy-lock.json), nie ląduje w repo
  linkTree = dir:
    builtins.listToAttrs (map (f: configEntry (builtins.substring 7 (-1) f))
      (filesUnder "config/${dir}"));

  # files: ~/.local/bin/<name> -> nixfiles/bin/<name>
  bin = names:
    builtins.listToAttrs (map (n: {
        name = ".local/bin/${n}";
        value.source = source "bin/${n}";
      })
      names);
}
