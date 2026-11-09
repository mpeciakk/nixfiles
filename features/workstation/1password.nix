{pkgs, ...}: {
  programs._1password.enable = true;
  programs._1password-gui = {
    enable = true;
    package = pkgs._1password-gui-beta;
    polkitPolicyOwners = ["m"];
  };

  environment.etc."1password/custom_allowed_browsers" = {
    text = "helium\n";
    mode = "0755";
  };
  environment.etc."chromium/native-messaging-hosts/com.1password.1password.json".text = builtins.toJSON {
    name = "com.1password.1password";
    description = "1Password BrowserSupport";
    path = "/run/wrappers/bin/1Password-BrowserSupport";
    type = "stdio";
    allowed_origins = ["chrome-extension://aeblfdkhhhdcdjpifhhbdiojplfjncoa/"];
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
