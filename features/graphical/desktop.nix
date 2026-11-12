{
  inputs,
  pkgs,
  dotfiles,
  ...
}: {
  hjem.users.m = {
    packages = with pkgs; [
      kitty
      quickshell
      xwayland-satellite
      cliphist
      wl-clipboard
      zed-editor
      legcord
      mpv
      ffmpeg
      playerctl
      catppuccin-cursors.mochaDark # theme set in niri config.kdl
      inputs.jfsh.packages.${pkgs.stdenv.hostPlatform.system}.default
    ];

    xdg.config.files =
      dotfiles.link "niri" ["config.kdl" "input.kdl" "layout.kdl" "workspace.kdl" "window_rules.kdl" "bindings.kdl" "animations.kdl"]
      // dotfiles.link "kitty" ["kitty.conf" "theme.conf"]
      // dotfiles.link "uwsm" ["env"]
      // dotfiles.link "mpv" ["mpv.conf"]
      // dotfiles.linkDir "wireplumber"
      // {
        "quickshell".source = "/home/m/projects/quickshell-dynamic-island";
        "xdg-terminals.list".source = dotfiles.source "config/xdg-terminals.list";
      };

    xdg.data.files = builtins.listToAttrs (map (n: {
      name = "applications/${n}.desktop";
      value.text = ''
        [Desktop Entry]
        Type=Application
        Name=${n}
        Hidden=true
      '';
    }) ["nvim" "nvidia-settings" "uuctl"]);
  };
}
