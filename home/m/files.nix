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
      // {"quickshell".source = "${dot}/quickshell";}
      // builtins.listToAttrs (map (n: {
        name = "git/${n}";
        value = {
          source = "${dot}/git/${n}";
          clobber = true;
        };
      }) ["config" "ignore"]);

    xdg.data.files = {
      "zoxide/init.nu" = shellInit "zoxide" "${pkgs.zoxide}/bin/zoxide init nushell";
      "atuin/init.nu" = shellInit "atuin" "${pkgs.atuin}/bin/atuin init nu";
    };

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
