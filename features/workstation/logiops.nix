{pkgs, ...}: let
  inherit ((pkgs.formats.libconfig {}).lib) mkHex mkArray;
  key = keys: {
    type = "Keypress";
    keys = mkArray keys;
  };
  gesture = direction: keys: {
    inherit direction;
    mode = "OnRelease";
    action = key keys;
  };
in {
  services.logiops = {
    enable = true;
    # with the default 500 ms logid missed the mouse after boot
    config.io_timeout = 2000.0;
    config.devices = [
      {
        name = "MX Master 3S";
        smartshift = {
          on = true;
          threshold = -1;
        };
        hiresscroll = {
          hires = false;
          invert = false;
          target = false;
        };
        dpi = 1500;
        # side buttons (0x53, 0x56) stay native BTN_SIDE/BTN_EXTRA: games bind them as
        # Button4/5, browsers handle back/forward themselves
        buttons = [
          {
            cid = mkHex "0xc3";
            action = {
              type = "Gestures";
              gestures = [
                (gesture "None" ["KEY_LEFTMETA" "KEY_O"])
                (gesture "Left" ["KEY_LEFTMETA" "KEY_RIGHT"])
                (gesture "Right" ["KEY_LEFTMETA" "KEY_LEFT"])
                (gesture "Up" ["KEY_LEFTMETA" "KEY_PAGEDOWN"])
                (gesture "Down" ["KEY_LEFTMETA" "KEY_PAGEUP"])
              ];
            };
          }
        ];
      }
    ];
  };
}
