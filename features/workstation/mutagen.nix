{
  pkgs,
  dotfiles,
  ...
}: {
  # pam_env: TTY logins, user units and the graphical session all find the same daemon
  environment.sessionVariables.MUTAGEN_DATA_DIRECTORY = "$HOME/.local/share/mutagen";
  # sync starts at boot, before uwsm reads the synced ~/.config/uwsm/env at login
  users.users.m.linger = true;

  hjem.users.m = {
    packages = [pkgs.mutagen];

    files = dotfiles.bin ["mutagen-check" "mutagen-sessions"];

    systemd.services.mutagen = {
      description = "Mutagen daemon";
      wantedBy = ["default.target"];
      restartTriggers = [pkgs.mutagen];
      path = [pkgs.openssh];
      serviceConfig = {
        ExecStart = "${pkgs.mutagen}/bin/mutagen daemon run";
        Restart = "on-failure";
      };
    };
  };
}
