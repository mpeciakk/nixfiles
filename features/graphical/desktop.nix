{
  inputs,
  pkgs,
  dotfiles,
  ...
}: {
  # PDF stays with Helium, which registers itself for it
  xdg.mime.defaultApplications =
    {"inode/directory" = "yazi.desktop";}
    // pkgs.lib.genAttrs (map (t: "image/${t}") ["png" "jpeg" "gif" "webp" "bmp" "avif" "tiff"]) (_: "imv.desktop");

  hjem.users.m = {
    packages = with pkgs; [
      kitty
      quickshell
      glib # gdbus: Wyspa's sleep monitor (no gdbus = the session sleeps unlocked, DESIGN W21)
      xwayland-satellite
      cliphist
      wl-clipboard
      zed-editor
      legcord
      mpv
      ffmpeg
      playerctl
      imv
      catppuccin-cursors.mochaDark # theme set in niri config.kdl
      inputs.jfsh.packages.${pkgs.stdenv.hostPlatform.system}.default
    ];

    xdg.config.files =
      dotfiles.link "niri" ["config.kdl" "input.kdl" "layout.kdl" "workspace.kdl" "window_rules.kdl" "bindings.kdl" "animations.kdl"]
      // dotfiles.link "kitty" ["kitty.conf" "theme.conf"]
      // dotfiles.link "uwsm" ["env"]
      // dotfiles.link "mpv" ["mpv.conf"]
      // {
        "quickshell".source = "/home/m/projects/quickshell-dynamic-island";
        "xdg-terminals.list".source = dotfiles.source "config/xdg-terminals.list";
      };

    xdg.data.files =
      builtins.listToAttrs (map (n: {
        name = "applications/${n}.desktop";
        value.text = ''
          [Desktop Entry]
          Type=Application
          Name=${n}
          Hidden=true
        '';
      }) ["nvim" "nvidia-settings" "uuctl"])
      // {
        # xdg-open outside a DE ignores Terminal=true and runs yazi without a tty, so the terminal goes into Exec
        "applications/yazi.desktop".text = ''
          [Desktop Entry]
          Type=Application
          Name=Yazi
          Icon=yazi
          Exec=kitty yazi %f
          Terminal=false
          MimeType=inode/directory;
        '';
      };
  };
}
