{pkgs, ...}: {
  hjem.users.m.systemd.services.mutagen = {
    description = "Mutagen daemon";
    wantedBy = ["default.target"];
    path = [pkgs.openssh];
    environment.MUTAGEN_DATA_DIRECTORY = "%h/.local/share/mutagen";
    serviceConfig = {
      ExecStart = "${pkgs.mutagen}/bin/mutagen daemon run";
      Restart = "on-failure";
    };
  };
}
