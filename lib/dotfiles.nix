let
  root = "/home/m/projects/nixfiles";

  # live repo path so edits skip a rebuild; a missing file fails eval, but a deleted one leaves a dangling link that fails hjem deactivation
  source = rel:
    if builtins.pathExists (../. + "/${rel}")
    then "${root}/${rel}"
    else throw "nixfiles: brak pliku ${rel}";

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

  # files: ~/.local/bin/<name> -> nixfiles/bin/<name>
  bin = names:
    builtins.listToAttrs (map (n: {
        name = ".local/bin/${n}";
        value.source = source "bin/${n}";
      })
      names);
}
