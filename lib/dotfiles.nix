let
  root = "/home/m/projects/nixfiles";

  # live repo path so edits skip a rebuild; a missing file fails eval, not hjem activation
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

  # reads the flake source: untracked files don't exist there
  subdirs = rel: let
    entries = builtins.readDir (../. + "/${rel}");
  in
    builtins.filter (n: entries.${n} == "directory") (builtins.attrNames entries);

  # xdg.config: "<dir>/<name>" -> nixfiles/config/<dir>/<name>
  link = dir: names: builtins.listToAttrs (map (n: configEntry "${dir}/${n}") names);

  # whole-dir symlink: new files show up without a rebuild
  linkDir = dir: builtins.listToAttrs [(configEntry dir)];

  # per-file links: files a program writes alongside (lazy-lock.json) stay out of the repo
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
