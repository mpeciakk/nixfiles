let
  dot = "/home/m/dotfiles/config";
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
      // {"quickshell".source = "${dot}/quickshell";};

    systemd.services.quickshell = {
      description = "Quickshell";
      after = ["graphical-session.target"];
      wantedBy = ["graphical-session.target"];
      enableDefaultPath = false;
      environment.QSG_RENDER_LOOP = "threaded";
      serviceConfig = {
        Type = "simple";
        ExecStart = "/etc/profiles/per-user/m/bin/quickshell";
        Restart = "on-failure";
      };
    };
  };
}
