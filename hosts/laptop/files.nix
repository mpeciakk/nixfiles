{
  hjem.users.m.xdg.config.files."dotfiles/wallpaper-dark.png".source = ./wallpaper-dark.png;
  hjem.users.m.xdg.config.files."dotfiles/wallpaper-light.png".source = ./wallpaper-light.png;

  hjem.users.m.xdg.config.files."niri/output.kdl".text = ''
    output "DP-1" {
        mode "2560x1440@74.924"
        scale 1
        position x=0 y=0
        focus-at-startup
    }

    output "eDP-1" {
        mode "2560x1664"
        scale 1.5
        position x=0 y=1440
    }
  '';
}
