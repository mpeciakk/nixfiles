rec {
  dot = "/home/m/dotfiles/config";

  # xdg.config: "<dir>/<name>" -> ~/dotfiles/config/<dir>/<name>
  link = dir: names:
    builtins.listToAttrs (map (n: {
        name = "${dir}/${n}";
        value.source = "${dot}/${dir}/${n}";
      })
      names);

  # files: ~/.local/bin/<name> -> ~/dotfiles/bin/<name>
  bin = names:
    builtins.listToAttrs (map (n: {
        name = ".local/bin/${n}";
        value.source = "/home/m/dotfiles/bin/${n}";
      })
      names);
}
