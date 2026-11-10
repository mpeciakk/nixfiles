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
      inputs.jfsh.packages.${pkgs.stdenv.hostPlatform.system}.default
    ];

    xdg.config.files =
      dotfiles.link "niri" ["config.kdl" "input.kdl" "layout.kdl" "workspace.kdl" "window_rules.kdl" "bindings.kdl" "animations.kdl"]
      // dotfiles.link "kitty" ["kitty.conf" "theme.conf"]
      // dotfiles.link "uwsm" ["env"]
      // dotfiles.link "mpv" ["mpv.conf"]
      // {"quickshell".source = "${dotfiles.dot}/quickshell";}
      // {"wireplumber".source = "${dotfiles.dot}/wireplumber";};
  };
}
