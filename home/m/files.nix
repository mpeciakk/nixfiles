{pkgs, ...}: let
  dot = "/home/m/dotfiles/config";
  shellInit = name: cmd: {
    source = pkgs.runCommand "${name}-init.nu" {} "HOME=$TMPDIR ${cmd} > $out";
    clobber = true;
  };
  link = dir: names:
    builtins.listToAttrs (map (n: {
        name = "${dir}/${n}";
        value.source = "${dot}/${dir}/${n}";
      })
      names);
in {
  hjem.users.m = {
    xdg.config.files =
      link "niri" ["config.kdl" "input.kdl" "layout.kdl" "workspace.kdl" "window_rules.kdl" "bindings.kdl" "animations.kdl"]
      // link "kitty" ["kitty.conf" "theme.conf"]
      // link "nushell" ["config.nu" "env.nu" "init.nu" "completions.nu" "aliases.nu"]
      // link "uwsm" ["env"]
      // link "mpv" ["mpv.conf"]
      // link "dotfiles" ["config.json"]
      // link "herdr" ["config.toml" "plugins/config/herdr-navigator/config.toml"]
      // link "herdr-automatic-rename" ["config.sh"]
      // {"quickshell".source = "${dot}/quickshell";}
      // {"wireplumber".source = "${dot}/wireplumber";}
      // {
        "uv/uv.toml".text = ''
          python-preference = "only-managed"
        '';
        "user-dirs.dirs".text = ''
          XDG_DESKTOP_DIR="$HOME/"
          XDG_DOCUMENTS_DIR="$HOME/documents"
          XDG_DOWNLOAD_DIR="$HOME/downloads"
          XDG_MUSIC_DIR="$HOME/"
          XDG_PICTURES_DIR="$HOME/pictures"
          XDG_PUBLICSHARE_DIR="$HOME/"
          XDG_TEMPLATES_DIR="$HOME/"
          XDG_VIDEOS_DIR="$HOME/"
          XDG_PROJECTS_DIR="$HOME/projects"
        '';
      }
      // builtins.listToAttrs (map (n: {
        name = "git/${n}";
        value = {
          source = "${dot}/git/${n}";
          clobber = true;
        };
      }) ["config" "ignore"]);

    files = builtins.listToAttrs (map (n: {
      name = ".local/bin/${n}";
      value.source = "/home/m/dotfiles/bin/${n}";
    }) ["herdr-here" "herdr-ssh" "mutagen-check" "mutagen-sessions" "claude-baseline"]);

    xdg.data.files = {
      "zoxide/init.nu" = shellInit "zoxide" "${pkgs.zoxide}/bin/zoxide init nushell";
      "atuin/init.nu" = shellInit "atuin" "${pkgs.atuin}/bin/atuin init nu";
    };
  };
}
