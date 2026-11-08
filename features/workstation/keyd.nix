{
  services.keyd = {
    enable = true;
    keyboards.default = {
      ids = ["*" "-0000:0000"];
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
    };
  };
}
