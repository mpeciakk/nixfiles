{
  boot.loader = {
    timeout = 1;
    systemd-boot = {
      enable = true;
      configurationLimit = 5;
    };
  };
}
