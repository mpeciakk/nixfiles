{lib, ...}: let
  settings = {
    main = {
      insert = "f13";
      capslock = "C-A-space";
    };
    meta = {
      c = "C-insert";
      v = "S-insert";
      x = "C-x";
      s = "C-s";
      a = "C-a";
      f = "C-f";
      z = "C-z";
      t = "C-t";
      w = "C-w";
      n = "C-n";
      r = "C-r";
      o = "C-o";
      p = "C-p";
      k = "C-k";
      i = "C-i";
      u = "C-u";
      equal = "C-equal";
      minus = "C-minus";
      "0" = "C-0";
    };
    "meta+shift" = {
      z = "C-S-z";
      p = "C-S-p";
      f = "M-S-f";
      r = "M-S-r";
      v = "M-S-v";
    };
    "meta+control" = {
      f = "M-C-f";
      r = "M-C-r";
    };
  };
in {
  # keyd exits with 15 on SIGTERM, which made every shutdown log a failed unit
  systemd.services.keyd.serviceConfig.SuccessExitStatus = "15";

  services.keyd = {
    enable = true;
    keyboards.default = {
      ids = ["*" "-0000:0000"];
      inherit settings;
    };
    # Keychron K8 in Windows mode swaps Alt and Super on both sides compared to Mac mode;
    # swap them back so the physical layout stays Ctrl, Alt, Super | Super, AltGr.
    # layer(...) keeps the meta layer above working; altgr keeps Polish AltGr letters.
    keyboards.keychron = {
      ids = ["05ac:024f"];
      settings = lib.recursiveUpdate settings {
        main = {
          leftalt = "layer(meta)";
          leftmeta = "layer(alt)";
          rightalt = "layer(meta)";
          rightmeta = "layer(altgr)";
        };
      };
    };
  };
}
