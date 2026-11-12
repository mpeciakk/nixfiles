{
  hjem.users.m.systemd.services.quickshell = {
    description = "Quickshell";
    after = ["graphical-session.target"];
    partOf = ["graphical-session.target"];
    wantedBy = ["graphical-session.target"];
    enableDefaultPath = false;
    environment.QSG_RENDER_LOOP = "threaded";
    serviceConfig = {
      Type = "simple";
      ExecStart = "/etc/profiles/per-user/m/bin/quickshell";
      Restart = "on-failure";
    };
  };
}
