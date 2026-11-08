{pkgs, ...}: {
  programs._1password.enable = true;
  programs._1password-gui = {
    enable = true;
    package = pkgs._1password-gui-beta;
    polkitPolicyOwners = ["m"];
  };

  hjem.users.m.systemd.services."1password" = {
    description = "1Password";
    after = ["graphical-session.target"];
    wantedBy = ["graphical-session.target"];
    enableDefaultPath = false;
    serviceConfig = {
      ExecStart = "/run/current-system/sw/bin/1password --silent";
      Restart = "on-failure";
    };
  };
}
